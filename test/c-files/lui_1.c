unsigned char x = 1;

int main(void) {
    unsigned ret;
    asm("lui	$2,1;" : "=r" (ret));
    ret = ret >> 16;
    return ret;
}
