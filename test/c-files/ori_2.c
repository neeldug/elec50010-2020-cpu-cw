unsigned x = 27;

int main(void) {
    x = x | 65535;
    return x-65535;
}
