#line 1 "C:/Users/Marcelo/Documents/Projetos/Microcontroladores/headlight-control-pic12f629/src/headlight_control.c"
#line 33 "C:/Users/Marcelo/Documents/Projetos/Microcontroladores/headlight-control-pic12f629/src/headlight_control.c"
volatile unsigned long millis_count = 0;
unsigned char turn_off_command = 0;



void interrupt() {


 if (T0IF_bit) {
 T0IF_bit = 0x00;
 TMR0 = 255 - 4;
 millis_count++;
 }
}



void main()
{
 CMCON = 0x07;
 OPTION_REG = 0x07;
 OPTION_REG &= ~(1 << 7);
 INTCON = 0xA0;
 TMR0 = 255 - 4;
 WPU |= (1 << 0);
 WPU |= (1 << 1);
 TRISIO = 0b0001011;
 GPIO = 0x00;

 while(1) {

 if (( GP0_bit  == 0)&&( GP3_bit  == 0)) {
 millis_count = 0;
 turn_off_command = 1;
 }


 if ( GP1_bit  == 0) {
  GP2_bit  = 1;
 turn_off_command = 0;
 }


 if ((turn_off_command == 1) && (millis_count >=  5000 )) {
  GP2_bit  = 0;
 turn_off_command = 0;
 }
 }
}
