unsigned a = 5;

int main(void) {
    a = a^65535;
    return a - 65530;
}


