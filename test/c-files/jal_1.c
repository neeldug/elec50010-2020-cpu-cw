int x = 3;
void foo();

__attribute__((section(".text.main"))) int main(void) {
    foo();
    return x;
}

void __attribute__ ((noinline)) foo(void) {
    x += 4;
}
