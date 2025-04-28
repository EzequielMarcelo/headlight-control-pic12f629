
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;headlight_control.c,37 :: 		void interrupt() {
;headlight_control.c,40 :: 		if (T0IF_bit) {
	BTFSS      T0IF_bit+0, 2
	GOTO       L_interrupt0
;headlight_control.c,41 :: 		T0IF_bit = 0x00;          // Limpa a flag de interrupção do Timer0
	BCF        T0IF_bit+0, 2
;headlight_control.c,42 :: 		TMR0 = 255 - 4;            // Reinicia o Timer0 para gerar interrupções a cada 1ms (prescaler 1:256)
	MOVLW      251
	MOVWF      TMR0+0
;headlight_control.c,43 :: 		millis_count++;            // Incrementa a contagem de milissegundos
	MOVF       _millis_count+0, 0
	MOVWF      R0+0
	MOVF       _millis_count+1, 0
	MOVWF      R0+1
	MOVF       _millis_count+2, 0
	MOVWF      R0+2
	MOVF       _millis_count+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _millis_count+0
	MOVF       R0+1, 0
	MOVWF      _millis_count+1
	MOVF       R0+2, 0
	MOVWF      _millis_count+2
	MOVF       R0+3, 0
	MOVWF      _millis_count+3
;headlight_control.c,44 :: 		}
L_interrupt0:
;headlight_control.c,45 :: 		} //end interrupt
L__interrupt9:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;headlight_control.c,49 :: 		void main()
;headlight_control.c,51 :: 		CMCON = 0x07;              // Desabilita comparadores
	MOVLW      7
	MOVWF      CMCON+0
;headlight_control.c,52 :: 		OPTION_REG = 0x07;         // Desativa GPPU e configura prescaler 1:256 para o Timer0
	MOVLW      7
	MOVWF      OPTION_REG+0
;headlight_control.c,53 :: 		OPTION_REG &= ~(1 << 7);   // Desativa GPPU para permitir pull-ups internos
	MOVLW      127
	ANDWF      OPTION_REG+0, 1
;headlight_control.c,54 :: 		INTCON = 0xA0;             // Habilita interrupções globais e do Timer0
	MOVLW      160
	MOVWF      INTCON+0
;headlight_control.c,55 :: 		TMR0 = 255 - 4;            // Configura o Timer0 para gerar interrupção a cada 1 ms (prescaler 1:256)
	MOVLW      251
	MOVWF      TMR0+0
;headlight_control.c,56 :: 		WPU |= (1 << 0);           // Ativa pull-up interno em GP0 (LOCK_SIGNAL)
	BSF        WPU+0, 0
;headlight_control.c,57 :: 		WPU |= (1 << 1);           // Ativa pull-up interno em GP1 (UNLOCK_SIGNAL)
	BSF        WPU+0, 1
;headlight_control.c,58 :: 		TRISIO = 0b00000011;       // GP0, GP1 como entradas; as demais como saída
	MOVLW      3
	MOVWF      TRISIO+0
;headlight_control.c,59 :: 		GPIO = 0x00;               // Inicializa todos os pinos baixos
	CLRF       GPIO+0
;headlight_control.c,61 :: 		while(1) {
L_main1:
;headlight_control.c,63 :: 		if (LOCK_SIGNAL == 0) {    // Se apertar trava
	BTFSC      GP0_bit+0, 0
	GOTO       L_main3
;headlight_control.c,64 :: 		millis_count = 0;       // Reseta o contador de tempo
	CLRF       _millis_count+0
	CLRF       _millis_count+1
	CLRF       _millis_count+2
	CLRF       _millis_count+3
;headlight_control.c,65 :: 		turn_off_command = 1;
	MOVLW      1
	MOVWF      _turn_off_command+0
;headlight_control.c,66 :: 		}
L_main3:
;headlight_control.c,69 :: 		if (UNLOCK_SIGNAL == 0) {   // Se apertar destrava
	BTFSC      GP1_bit+0, 1
	GOTO       L_main4
;headlight_control.c,70 :: 		HEADLIGHT = 1;           // Liga o farol
	BSF        GP2_bit+0, 2
;headlight_control.c,71 :: 		turn_off_command = 0;
	CLRF       _turn_off_command+0
;headlight_control.c,72 :: 		}
L_main4:
;headlight_control.c,75 :: 		if ((turn_off_command == 1) && (millis_count >= DELAY_OFF)) {
	MOVF       _turn_off_command+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main7
	MOVLW      0
	SUBWF      _millis_count+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main10
	MOVLW      0
	SUBWF      _millis_count+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main10
	MOVLW      19
	SUBWF      _millis_count+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main10
	MOVLW      136
	SUBWF      _millis_count+0, 0
L__main10:
	BTFSS      STATUS+0, 0
	GOTO       L_main7
L__main8:
;headlight_control.c,76 :: 		HEADLIGHT = 0;            // Desliga o farol após o delay
	BCF        GP2_bit+0, 2
;headlight_control.c,77 :: 		turn_off_command = 0;     //Reseta flag
	CLRF       _turn_off_command+0
;headlight_control.c,78 :: 		}
L_main7:
;headlight_control.c,79 :: 		}
	GOTO       L_main1
;headlight_control.c,80 :: 		}
	GOTO       $+0
; end of _main
