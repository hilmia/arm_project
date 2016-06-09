.section .data


.globl game_row_end

game_row:
  .rept 20
  .int 0
  .endr
game_row_end:

.globl player_position
player_position:
  .int 10
