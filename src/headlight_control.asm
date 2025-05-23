
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;headlight_control.c,38 :: 		void interrupt() {
;headlight_control.c,41 :: 		if (T0IF_bit) {
	BTFSS      T0IF_bit+0, 2
	GOTO       L_interrupt0
;headlight_control.c,42 :: 		T0IF_bit = 0x00;          // Limpa a flag de interrup��o do Timer0
	BCF        T0IF_bit+0, 2
;headlight_control.c,43 :: 		TMR0 = 255 - 4;            // Reinicia o Timer0 para gerar interrup��es a cada 1ms (prescaler 1:256)
	MOVLW      251
	MOVWF      TMR0+0
;headlight_control.c,44 :: 		millis_count++;            // Incrementa a contagem de milissegundos
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
;headlight_control.c,45 :: 		}
L_interrupt0:
;headlight_control.c,46 :: 		} //end interrupt
L__interrupt12:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;headlight_control.c,50 :: 		void main()
;headlight_control.c,52 :: 		CMCON = 0x07;              // Desabilita comparadores
	MOVLW      7
	MOVWF      CMCON+0
;headlight_control.c,53 :: 		OPTION_REG = 0x07;         // Desativa GPPU e configura prescaler 1:256 para o Timer0
	MOVLW      7
	MOVWF      OPTION_REG+0
;headlight_control.c,54 :: 		OPTION_REG &= ~(1 << 7);   // Desativa GPPU para permitir pull-ups internos
	MOVLW      127
	ANDWF      OPTION_REG+0, 1
;headlight_control.c,55 :: 		INTCON = 0xA0;             // Habilita interrup��es globais e do Timer0
	MOVLW      160
	MOVWF      INTCON+0
;headlight_control.c,56 :: 		TMR0 = 255 - 4;            // Configura o Timer0 para gerar interrup��o a cada 1 ms (prescaler 1:256)
	MOVLW      251
	MOVWF      TMR0+0
;headlight_control.c,57 :: 		WPU |= (1 << 0);           // Ativa pull-up interno em GP0 (LOCK_SIGNAL)
	BSF        WPU+0, 0
;headlight_control.c,58 :: 		WPU |= (1 << 1);           // Ativa pull-up interno em GP1 (UNLOCK_SIGNAL)
	BSF        WPU+0, 1
;headlight_control.c,59 :: 		TRISIO = 0b0001011;       // GP0, GP1 e GP3 como entradas; as demais como sa�da
	MOVLW      11
	MOVWF      TRISIO+0
;headlight_control.c,60 :: 		GPIO = 0x00;               // Inicializa todos os pinos baixos
	CLRF       GPIO+0
;headlight_control.c,62 :: 		while(1) {
L_main1:
;headlight_control.c,64 :: 		if ((LOCK_SIGNAL == 0)&&(IGNITION_SIGNAL == 0)) {    // Se apertar trava
	BTFSC      GP0_bit+0, 0
	GOTO       L_main5
	BTFSC      GP3_bit+0, 3
	GOTO       L_main5
L__main11:
;headlight_control.c,65 :: 		millis_count = 0;       // Reseta o contador de tempo
	CLRF       _millis_count+0
	CLRF       _millis_count+1
	CLRF       _millis_count+2
	CLRF       _millis_count+3
;headlight_control.c,66 :: 		turn_off_command = 1;
	MOVLW      1
	MOVWF      _turn_off_command+0
;headlight_control.c,67 :: 		}
L_main5:
;headlight_control.c,70 :: 		if (UNLOCK_SIGNAL == 0) {   // Se apertar destrava
	BTFSC      GP1_bit+0, 1
	GOTO       L_main6
;headlight_control.c,71 :: 		HEADLIGHT = 1;           // Liga o farol
	BSF        GP2_bit+0, 2
;headlight_control.c,72 :: 		turn_off_command = 0;
	CLRF       _turn_off_command+0
;headlight_control.c,73 :: 		}
L_main6:
;headlight_control.c,76 :: 		if ((turn_off_command == 1) && (millis_count >= DELAY_OFF)) {
	MOVF       _turn_off_command+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main9
	MOVLW      0
	SUBWF      _millis_count+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main13
	MOVLW      0
	SUBWF      _millis_count+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main13
	MOVLW      19
	SUBWF      _millis_count+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main13
	MOVLW      136
	SUBWF      _millis_count+0, 0
L__main13:
	BTFSS      STATUS+0, 0
	GOTO       L_main9
L__main10:
;headlight_control.c,77 :: 		HEADLIGHT = 0;            // Desliga o farol ap�s o delay
	BCF        GP2_bit+0, 2
;headlight_control.c,78 :: 		turn_off_command = 0;     //Reseta flag
	CLRF       _turn_off_command+0
;headlight_control.c,79 :: 		}
L_main9:
;headlight_control.c,80 :: 		}
	GOTO       L_main1
;headlight_control.c,81 :: 		}
	GOTO       $+0
; end of _main
