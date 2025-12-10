import asyncio
import os
import sys
import time
from playwright.async_api import async_playwright

# Configuration
CDP_URL = "http://localhost:9222"
OUTPUT_DIR = "generated_images"

async def generate_images(prompt):
    """
    Connects to an existing Chrome instance via CDP, sends a prompt to Gemini,
    and attempts to download the generated image.
    """
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    async with async_playwright() as p:
        try:
            print(f"Connecting to browser at {CDP_URL}...")
            browser = await p.chromium.connect_over_cdp(CDP_URL)
        except Exception as e:
            print(f"Error connecting to browser: {e}")
            print("\n[IMPORTANT] Please ensure Chrome is running with remote debugging enabled:")
            print("  google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug")
            return

        # Get the active context
        context = browser.contexts[0]
        
        # Find the Gemini tab or open a new one
        page = None
        for p_page in context.pages:
            if "gemini.google.com" in p_page.url:
                page = p_page
                print("Found existing Gemini tab.")
                break
        
        if not page:
            print("Opening new Gemini tab...")
            page = await context.new_page()
            await page.goto("https://gemini.google.com/app")

        # Wait for the page to be ready
        await page.wait_for_load_state("networkidle")

        # Selector for the input box (Rich text editor content)
        # Note: This selector is based on common structure but might change.
        # We look for the contenteditable div in the main chat area.
        input_selector = "div[contenteditable='true']"
        
        try:
            await page.wait_for_selector(input_selector, timeout=10000)
        except:
            print("Could not find input box. You might need to log in manually first.")
            return

        # Type the prompt
        print(f"Sending prompt: {prompt}")
        await page.click(input_selector)
        await page.fill(input_selector, f"Generate an image of {prompt}")
        await page.keyboard.press("Enter")

        print("Waiting for generation (approx 20 seconds)...")
        # Wait for generation. This is a heuristic wait.
        # Ideally, we would wait for a specific element that indicates completion.
        await asyncio.sleep(20)

        # Attempt to find generated images
        # Gemini usually puts images in <img> tags within the message stream.
        # We'll look for the last few images.
        print("Scanning for generated images...")
        
        # Take a screenshot for debugging/verification
        timestamp = int(time.time())
        debug_screenshot = os.path.join(OUTPUT_DIR, f"debug_{timestamp}.png")
        await page.screenshot(path=debug_screenshot)
        print(f"Saved debug screenshot to {debug_screenshot}")

        # Simple logic: Find all images that look like generated content (usually large)
        # This part is fragile and might need adjustment based on actual DOM.
        # For now, we just notify the user that the process finished.
        
        print("Process finished. Please check the browser window to see the result.")
        print("To automate downloading, we would need to inspect the specific DOM structure of the generated image container.")

        # Do not close the browser as it's a persistent user session
        await browser.disconnect()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        prompt_text = " ".join(sys.argv[1:])
    else:
        prompt_text = "a futuristic eco-friendly city with vertical gardens"
    
    asyncio.run(generate_images(prompt_text))
