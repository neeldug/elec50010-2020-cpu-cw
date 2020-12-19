volatile unsigned char y = 7;
volatile unsigned char x = 5;

int main(void) {
    x = 4;
    return y-x;
}
