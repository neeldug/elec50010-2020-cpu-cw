volatile unsigned short y = 36;
volatile unsigned short x = 27;

int main(void) {
    x = 4;
    return y-x;
}
