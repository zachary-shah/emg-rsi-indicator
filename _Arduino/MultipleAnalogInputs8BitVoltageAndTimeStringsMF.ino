//ARDUINO BAUDRATE 500000 

//THE CURRENT SETUP IN THIS CODE PROVIDES 1200 SAMPLES PER SECOND ON THE ANALOG INPUTS

//THE OUTPUTS ARE THE DIGITIZED SIGNALS (0-255; 8-BIT) AND THE TIME BETWEEN SAMPLES 

//  IN 4 MICROSECOND INCREMENTS (E.G. 100 = 400µs) ON EACH CHANNEL 

  

//ENTER ANALOG PIN TO READ FROM AND NUMBER OF MULTIPLEXER INPUTS 

const uint8_t arduino_analog_pins[] = {0,1}; 

const uint8_t number_of_inputs = sizeof(arduino_analog_pins); 

  

//Variable definitions 

const float target_adc_frequency_in_kHz = 1.2 * 2 * number_of_inputs;

volatile uint8_t analog_pin_index = 0;

volatile uint8_t adc_now = 0; 

String serial_string = ""; 

const uint8_t buffer_length = 8 * number_of_inputs * 4; 

volatile char serial_chars_buffer1[buffer_length]; 

volatile char serial_chars_buffer2[buffer_length]; 

volatile uint8_t buffer_index = 0; 

volatile boolean buffer1_flag = true; 

volatile boolean read_flag = false; 

const char char_reference[] = {'0','1','2','3','4','5','6','7','8','9'}; 

volatile uint8_t current_time_fourth = 0; 

volatile uint8_t last_calls[number_of_inputs]; 

volatile uint8_t time_delta_fourth = 0;

  

void setup() 

{ 

  // Initialize serial chars 

  // - Set buffer elements to 0 characters 

  for (int i = 0; i < buffer_length; i++) 

  { 

    serial_chars_buffer1[i] = '0'; 

    serial_chars_buffer2[i] = '0'; 

  } 

  // - Set every 4th element to a comma (divide into 3 digit numbers) 

  for (int i = 3; i < buffer_length; i+=4) 

  { 

    serial_chars_buffer1[i] = ','; 

    serial_chars_buffer2[i] = ','; 

  } 

  // - Set elements at the end of data blocks (single set of input values) to newlines 

  for (int i = number_of_inputs * 8 - 1; i < buffer_length; i+=number_of_inputs * 8) 

  { 

    serial_chars_buffer1[i] = '\n'; 

    serial_chars_buffer2[i] = '\n'; 

  } 
   
  InitializeADCSettings();

  // Baud Rate Setup 

  Serial.begin(500000); 

  Serial.flush(); 

} 

  

void loop() 

{ 

  if (read_flag) 

  { 

    if (buffer1_flag) 

    { 

      Serial.write ((char *)serial_chars_buffer1, buffer_length); 

    } else 

    { 

      Serial.write ((char *)serial_chars_buffer2, buffer_length); 

    } 

    read_flag = false; 

  } 

} 

  

// Interrupt service routine for the ADC completion 

ISR(ADC_vect) 

{ 

  current_time_fourth = micros()/4;// (divided by 4 to keep time delta below 256) 

  time_delta_fourth = current_time_fourth - last_calls[analog_pin_index];// time delta - in units of 4µs 

   

  // For 8-bit resolution (for operating with a prescaler as low as 16) 

  adc_now = ADCH;// current ADC value 

   

  // Choose buffer to write to 

  if (buffer1_flag) 

  { 

    // Assign characters that represent ADC conversion and time delta 

    serial_chars_buffer1[buffer_index] = char_reference[adc_now/100];// ADC 100s 

    serial_chars_buffer1[buffer_index + 1] = char_reference[(adc_now%100)/10];// ADC 10s 

    serial_chars_buffer1[buffer_index + 2] = char_reference[adc_now%10];// ADC 1s 

    serial_chars_buffer1[buffer_index + 4] = char_reference[time_delta_fourth/100];// time delta 100s 

    serial_chars_buffer1[buffer_index + 5] = char_reference[(time_delta_fourth%100)/10];// time delta 10s 

    serial_chars_buffer1[buffer_index + 6] = char_reference[time_delta_fourth%10];// time delta 1s 

  } else 

  { 

    // Assign characters that represent ADC conversion and time delta 

    serial_chars_buffer2[buffer_index] = char_reference[adc_now/100];// ADC 100s 

    serial_chars_buffer2[buffer_index + 1] = char_reference[(adc_now%100)/10];// ADC 10s 

    serial_chars_buffer2[buffer_index + 2] = char_reference[adc_now%10];// ADC 1s 

    serial_chars_buffer2[buffer_index + 4] = char_reference[time_delta_fourth/100];// time delta 100s 

    serial_chars_buffer2[buffer_index + 5] = char_reference[(time_delta_fourth%100)/10];// time delta 10s 

    serial_chars_buffer2[buffer_index + 6] = char_reference[time_delta_fourth%10];// time delta 1s 

  } 

  

  // Update buffer index (position in current character buffer) 

  buffer_index = (buffer_index + 8) % buffer_length; 

  

  // Check to see if the current buffer is full (and switch buffers if needed) 

  if (buffer_index == 0) 

  { 

    buffer1_flag = !buffer1_flag; 

    read_flag = true; 

  } 

  

  // Update ADC call history 

  last_calls[analog_pin_index] = current_time_fourth; 


  // Increment analog input pin 

  analog_pin_index = (analog_pin_index + 1) % number_of_inputs;

  // Set analog pin index for ADC
  
  ADMUX = bit (REFS0) | bit (ADLAR) | (arduino_analog_pins[analog_pin_index] & 7); 

} 

  

// Timer interrupt needs to be created, but currently does nothing 

ISR(TIMER1_COMPB_vect) 

{ 

} 

void InitializeADCSettings()
{
  // Disable global interrupts 

  cli(); 
  
  // Set up Timer 1 to interrupt at target frequency (for Compare Match B) 

  TCCR1A = 0;// clear register 

  TCCR1B = 0;// clear register 

  TCNT1  = 0;//initialize counter value to 0 

  TCCR1B |= bit (WGM12);// clear timer on match (reset) 

  TCCR1B |= bit (CS10);// set prescaler to 1 

  TIMSK1 |= bit (OCIE1B);// enable timer compare interrupt 

  OCR1B = 16000000 / (target_adc_frequency_in_kHz * 1000); 

  OCR1A = OCR1B; 

   

  // Initialize Analog Reference (AVcc), Left Adjust, and Analog Pin to Read 

  // With ADLAR bit set, just read ADCH (reduce to 8-bit resolution) 

  ADMUX = bit (REFS0) | bit (ADLAR) | (arduino_analog_pins[analog_pin_index] & 7); 

  

  // Clear ADTS2..0 in ADCSRB (0x7B) to set trigger mode to Timer/Counter 1 Compare Match B (1 0 1). 

  // This means ADC will be triggered by Timer 1 

  ADCSRB |= bit (ADTS0) | bit (ADTS2); 

  

  ADCSRA = bit (ADEN) // Enable ADC 

          | bit (ADIE) // Enable Interrupt 

          | bit (ADATE); // Enable Auto-Trigger 

  

  // Set the Prescaler (16000KHz/128 = 125KHz) 

  // Above 200KHz 10-bit results are not reliable. 

  // About 8-bit resolution up to 1MHz (Prescaler = 16) 

  //ADCSRA |= bit (ADPS0);                               //   2  No precision 

  //ADCSRA |= bit (ADPS1);                               //   4  No precision 

  //ADCSRA |= bit (ADPS0) | bit (ADPS1);                 //   8  Low precision 

  ADCSRA |= bit (ADPS2);                               //  16  Okay precision  (up to 77K conversions/s) 

  //ADCSRA |= bit (ADPS0) | bit (ADPS2);                 //  32 Good precision (up to 38.5K conversions/s) 

  //ADCSRA |= bit (ADPS1) | bit (ADPS2);                 //  64 Good precision (up to 19.2K conversions/s) 

  //ADCSRA |= bit (ADPS0) | bit (ADPS1) | bit (ADPS2);   // 128 Most precision (up to 9.6K conversions/s) 

   

  // Enable global interrupts 

  sei(); 
}
