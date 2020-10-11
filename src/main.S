.syntax unified
.global main
.type main, %function

.data
section1:
.word 0x82, 0, 0, 0, 0x82, 0, 0x57, 0, 0x61, 0, 0, 0, 0x6d, 0, 0, 0, 0x74, 0, 0, 0, 0x74, 0, 0x74, 0, 0x61, 0, 0, 0,  0x6d, 0, 0x74, 0,  0x82, 0, 0, 0,  0x82, 0,  0x37, 0,  0x3a, 0,  0x37, 0,   0x3a, 0, 0x37, 0, 0x82, 0, 0, 0,  0x82, 0, 0x37, 0,0x3a, 0,  0x37, 0,  0x3a, 0,0x37, 0

section2: 
.word 0x6d,0, 0x6d,0, 0x6d,0, 0x6d,0,  0x57,0, 0x57,0, 0x57,0, 0x57, 0, 0x61,0, 0x61,0, 0x61,0,0x61, 0, 0x49,0, 0x49,0, 0x49,0, 0x49, 0, 0x41,0, 0x41,0, 0x41,0, 0x41,0, 0x41,0, 0x41,0, 0x41,0, 0x41,0, 0x41,0, 0x41,0, 0x41,0, 0x41,0,0x5b,0, 0x6d,0, 0x74, 0,0x89,0



.text
main: 
mov r11, 2
mov r8, 0
mov r6, 0
push {r6}
bl init
@ bl BSP_AUDIO_Buffer


sequencer:

@setting time index
mov r10, 0

@load array and set how many points to be plotted and increase sequence index
pop {r6}
bl sequence_changer
ldr r5, [r0, r4]

@set peak amplitude
cmp r6, 0x40
ite lt
addlt r8, r8, 0x200
movge r8, 0x7fff


@increase sequence index
add r6, r6, 1
push {r6}

@setting time
mov r9, 0x1770
cmp r6, 0x140
it gt
subgt r9, r9, 0x32

@calculate increment or decrement
bl calculate_increment

@play quietly at certain index or play normally
cmp r5, 0
it eq
bleq stepper2
it ne
blne stepper1   

@increase array index
add r4, 4

@end if the array is finished
cmp r4, 0x100
it eq
moveq r4, 0

@Loop sequencer
b sequencer

stepper1:    @pushes the next step link in sequence into stack
push {lr}
cmp r6, 0x100   
itt eq 
moveq r6, 0
beq square_wave_1   @change the waveform

@setting plot index
mov r6, 0

b decrement_loop

stepper2:
push {lr}

@setting plot index
mov r6, 0

b no_sound


@the loops to create a triangle wave
decrement_loop: @Amplitude of the plot decreases
cmp r6, r5
beq increment_loop
mov r0, r8
bl BSP_AUDIO_OUT_Play_Sample
subs r8, r8, r7    @decrement vertical value
add r6, 1   @increase plot index
add r10,1   @increase time index
cmp r9, r10
itt eq      @if times is up then go back to sequencer
popeq {lr}
bxeq lr
b decrement_loop

increment_loop: @Amplitude of plot increases
cmp r6, 0
beq decrement_loop
mov r0, r8
bl BSP_AUDIO_OUT_Play_Sample
adds r8, r8, r7     @increment vertical value
sub r6, 1  @decrease plot index
add r10,1  @increase time index
cmp r9, r10
itt eq     @if time is up then go back to sequencer
popeq {lr}
bxeq lr
b increment_loop

no_sound:      @plays wave with amplitude 0
mov r0, 0
bl BSP_AUDIO_OUT_Play_Sample
cmp r9,r10
itt eq
popeq {lr}
bxeq lr
add r10, 1
b no_sound

calculate_increment: @calculate the amplitude change between two plots
mov r11, 2
mul r11, r11, r8
udiv r7, r11 , r5
bx lr

sequence_changer: @determines when to play which sequence
ldr r0, =section1
cmp r6, 0xc0
it gt
ldrgt r0, =section2
cmp r6, 0x100
it gt 
ldrgt r0, =section1
bx lr

square_wave_1:
cmp r6, r5
beq square_wave_2
mov r0, 0x7fff
bl BSP_AUDIO_OUT_Play_Sample
add r6, 1
add r10, 1
cmp r9, r10
itt eq     @if time is up then go back to sequencer
popeq {lr}
bxeq lr
b square_wave_1

square_wave_2:
cmp r6, 0
beq square_wave_1
mov r0, 0x8000
bl BSP_AUDIO_OUT_Play_Sample
sub r6, 1
add r10,1
cmp r9, r10
itt eq     @if time is up then go back to sequencer
popeq {lr}
bxeq lr
b square_wave_2