/* ============================================================================

   Controle de farol atrav�s dos sinais de trava e destrava do alarme

   Sinal de trava LOW
   Sinal de destrava LOW

   Ao travar desliga o farol ap�s um delay (usando Timer)
   Ao destravar acende o farol sem delay

   MCU: PIC12F629
   Clock: Interno 4MHz
   Compilador: MikroC Pro For PIC v.4.15.0.0

   Autor: Marcelo Gustavo Ezequiel
   Data: Abril de 2025

============================================================================ */

// ============================================================================
// --- Mapeamento de Hardware ---
#define   LOCK_SIGNAL         GP0_bit         // Entrada para pulso de trava
#define   UNLOCK_SIGNAL       GP1_bit         // Entrada para pulso de destrava
#define   HEADLIGHT           GP2_bit         // Sa�da para controle do farol
#define   IGNITION_SIGNAL     GP3_bit         //Entrada do pos chave

// ============================================================================
// --- Constantes Auxiliares ---
#define   DELAY_OFF            5000           // Delay em milissegundos

// ============================================================================
// --- Vari�veis Globais ---
volatile unsigned long millis_count = 0;   // Contador global de milissegundos
unsigned char turn_off_command = 0;

// ============================================================================
// --- Interrup��es ---
void interrupt() {
    // +++ Interrup��o do Timer0 +++
    // Verifica se houve interrup��o do Timer0
    if (T0IF_bit) {
        T0IF_bit = 0x00;          // Limpa a flag de interrup��o do Timer0
        TMR0 = 255 - 4;            // Reinicia o Timer0 para gerar interrup��es a cada 1ms (prescaler 1:256)
        millis_count++;            // Incrementa a contagem de milissegundos
    }
} //end interrupt

// ============================================================================
// Fun��o Principal
void main()
{
    CMCON = 0x07;              // Desabilita comparadores
    OPTION_REG = 0x07;         // Desativa GPPU e configura prescaler 1:256 para o Timer0
    OPTION_REG &= ~(1 << 7);   // Desativa GPPU para permitir pull-ups internos
    INTCON = 0xA0;             // Habilita interrup��es globais e do Timer0
    TMR0 = 255 - 4;            // Configura o Timer0 para gerar interrup��o a cada 1 ms (prescaler 1:256)
    WPU |= (1 << 0);           // Ativa pull-up interno em GP0 (LOCK_SIGNAL)
    WPU |= (1 << 1);           // Ativa pull-up interno em GP1 (UNLOCK_SIGNAL)
    TRISIO = 0b0001011;       // GP0, GP1 e GP3 como entradas; as demais como sa�da
    GPIO = 0x00;               // Inicializa todos os pinos baixos
    
    while(1) {
        // Verifica bot�o de TRAVA
        if ((LOCK_SIGNAL == 0) && (IGNITION_SIGNAL == 0)) {    // Se apertar trava
           millis_count = 0;       // Reseta o contador de tempo
           turn_off_command = 1;
        }

        // Verifica bot�o de DESTRAVA
        if (UNLOCK_SIGNAL == 0) {   // Se apertar destrava
           HEADLIGHT = 1;           // Liga o farol
           turn_off_command = 0;
        }

        // Verifica se o tempo de delay foi atingido
        if ((turn_off_command == 1) && (millis_count >= DELAY_OFF)) {
            HEADLIGHT = 0;            // Desliga o farol ap�s o delay
            turn_off_command = 0;     //Reseta flag
        }
    }
}