import matplotlib.pyplot as plt
import matplotlib.patches as patches
import matplotlib.path as mpath
import numpy as np

def create_icon_with_reminder():
    # 1. キャンバスの設定
    fig, ax = plt.subplots(figsize=(5, 5))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # カラーパレット (Modern Obsidian Theme)
    bg_color = "#0f172a"       # 濃いネイビー（背景）
    clock_face = "#1e293b"     # カード色（文字盤）
    accent = "#38bdf8"         # シアン（アクセント）
    hand_color = "#f8fafc"     # 白（針）
    
    # 2. 背景（アプリアイコン風の角丸四角）
    rect = patches.FancyBboxPatch(
        (5, 5), 90, 90,
        boxstyle="round,pad=0,rounding_size=20",
        facecolor=bg_color, edgecolor="none"
    )
    ax.add_patch(rect)

    # 3. 時計の文字盤
    circle = patches.Circle(
        (50, 50), 35,
        facecolor=clock_face, edgecolor=accent, linewidth=2
    )
    ax.add_patch(circle)

    # 4. 目盛り（シンプルに）
    for i in range(0, 360, 30):
        angle = np.radians(i)
        # 3, 6, 9, 12時は長く、それ以外は短く
        length = 7 if i % 90 == 0 else 4
        width = 3 if i % 90 == 0 else 1.5
        
        x1 = 50 + (35 - length) * np.cos(angle)
        y1 = 50 + (35 - length) * np.sin(angle)
        x2 = 50 + 35 * np.cos(angle)
        y2 = 50 + 35 * np.sin(angle)
        
        # リマインダーアイコンと被るため、6時(270度)の目盛りは描かない、または短くする
        if i == 270: continue 

        ax.add_patch(patches.ConnectionPatch(
            (x1, y1), (x2, y2), "data", "data", color=accent, linewidth=width
        ))

    # 5. リマインダーアイコン（ベル）の描画
    # 位置: 中央下 (50, 25)あたり
    icon_center_x = 50
    icon_center_y = 25
    
    # 5-1. 台座（バッジ背景）
    badge_radius = 8
    badge = patches.Circle(
        (icon_center_x, icon_center_y), badge_radius,
        facecolor=accent, edgecolor=bg_color, linewidth=1, zorder=5
    )
    ax.add_patch(badge)

    # 5-2. ベルの本体（パスで描画）
    # ベルの色は背景色にして「切り抜き」風に見せる
    bell_color = bg_color 
    
    verts = [
        (icon_center_x - 3, icon_center_y - 1), # 左下
        (icon_center_x - 2, icon_center_y + 4), # 左肩
        (icon_center_x + 2, icon_center_y + 4), # 右肩
        (icon_center_x + 3, icon_center_y - 1), # 右下
        (icon_center_x - 3, icon_center_y - 1), # 閉じる
    ]
    codes = [
        mpath.Path.MOVETO,
        mpath.Path.CURVE3, # ベジェ曲線で丸みをつける
        mpath.Path.CURVE3,
        mpath.Path.LINETO,
        mpath.Path.CLOSEPOLY,
    ]
    path = mpath.Path(verts, codes)
    bell_body = patches.PathPatch(path, facecolor=bell_color, zorder=6)
    ax.add_patch(bell_body)
    
    # 5-3. ベルの振り子（下の丸）
    clapper = patches.Circle(
        (icon_center_x, icon_center_y - 2.5), 1.2,
        facecolor=bell_color, zorder=6
    )
    ax.add_patch(clapper)

    # 6. 時計の針（10時10分）
    # 針がアイコンの上にくるように zorder を高く設定
    
    # 短針
    h_angle = np.radians(150)
    hx = 50 + 18 * np.cos(h_angle)
    hy = 50 + 18 * np.sin(h_angle)
    ax.add_patch(patches.ConnectionPatch(
        (50, 50), (hx, hy), "data", "data",
        color=hand_color, linewidth=4, capstyle='round', zorder=10
    ))

    # 長針
    m_angle = np.radians(30)
    mx = 50 + 26 * np.cos(m_angle)
    my = 50 + 26 * np.sin(m_angle)
    ax.add_patch(patches.ConnectionPatch(
        (50, 50), (mx, my), "data", "data",
        color=accent, linewidth=3, capstyle='round', zorder=10
    ))

    # 中心点
    ax.add_patch(patches.Circle((50, 50), 3, color=accent, zorder=11))

    # 保存
    plt.savefig('icon_reminder.png', dpi=300, bbox_inches='tight', transparent=True)
    print("生成完了: icon_reminder.png")

create_icon_with_reminder()