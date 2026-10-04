# Minesweeper (Godot 4)

A simple Minesweeper clone made with Godot 4 and GDScript.

Godot 4 と GDScript で作ったシンプルなマインスイーパです。

## Features / 機能

- 9x9 grid
- Adjustable number of mines (1-79) / 地雷数を変更可能（1〜79）
- Time limit (120 seconds) / 制限時間あり（120秒）
- Flags with right click / 右クリックで旗を立てる
- The first click is always safe / 最初のクリックは必ず安全
- Auto-reveal of empty areas / 周囲に地雷がないマスは連鎖して開く

## Controls / 操作

| Action | Control |
| --- | --- |
| Reveal a cell / マスを開く | Left click |
| Place or remove a flag / 旗の設置・解除 | Right click |
| Restart / リスタート | `R` key or Start button |

## How to run / 遊び方

1. Install [Godot 4](https://godotengine.org/)
2. Clone this repository
3. Open `project.godot` from the Godot project manager
4. Press `F5` to run
