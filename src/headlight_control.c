/* ============================================================================

   Controle de farol através dos sinais de trava e destrava do alarme

   Sinal de trava LOW
   Sinal de destrava LOW

   Ao travar desliga o farol após um delay (usando Timer)
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
#define   HEADLIGHT           GP2_bit         // Saída para controle do farol

// ============================================================================
// --- Constantes Auxiliares ---
#define   DELAY_OFF            5000           // Delay em milissegundos

// ============================================================================
// --- Variáveis Globais ---
volatile unsigned long millis_count = 0;   // Contador global de milissegundos
unsigned char turn_off_command = 0;

// ============================================================================
// --- Interrupções ---
void interrupt() {
    // +++ Interrupção do Timer0 +++
    // Verifica se houve interrupção do Timer0
    if (T0IF_bit) {
        T0IF_bit = 0x00;          // Limpa a flag de interrupção do Timer0
        TMR0 = 255 - 4;            // Reinicia o Timer0 para gerar interrupções a cada 1ms (prescaler 1:256)
        millis_count++;            // Incrementa a contagem de milissegundos
    }
} //end interrupt

// ============================================================================
// Função Principal
void main()
{
    CMCON = 0x07;              // Desabilita comparadores
    OPTION_REG = 0x07;         // Desativa GPPU e configura prescaler 1:256 para o Timer0
    OPTION_REG &= ~(1 << 7);   // Desativa GPPU para permitir pull-ups internos
    INTCON = 0xA0;             // Habilita interrupções globais e do Timer0
    TMR0 = 255 - 4;            // Configura o Timer0 para gerar interrupção a cada 1 ms (prescaler 1:256)
    WPU |= (1 << 0);           // Ativa pull-up interno em GP0 (LOCK_SIGNAL)
    WPU |= (1 << 1);           // Ativa pull-up interno em GP1 (UNLOCK_SIGNAL)
    TRISIO = 0b00000011;       // GP0, GP1 como entradas; as demais como saída
    GPIO = 0x00;               // Inicializa todos os pinos baixos
    
    while(1) {
        // Verifica botão de TRAVA
        if (LOCK_SIGNAL == 0) {    // Se apertar trava
           millis_count = 0;       // Reseta o contador de tempo
           turn_off_command = 1;
        }

        // Verifica botão de DESTRAVA
        if (UNLOCK_SIGNAL == 0) {   // Se apertar destrava
           HEADLIGHT = 1;           // Liga o farol
           turn_off_command = 0;
        }

        // Verifica se o tempo de delay foi atingido
        if ((turn_off_command == 1) && (millis_count >= DELAY_OFF)) {
            HEADLIGHT = 0;            // Desliga o farol após o delay
            turn_off_command = 0;     //Reseta flag
        }
    }
}