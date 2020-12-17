unsigned t = 8;

int main(void) {
    unsigned f1 = 0;
    unsigned f2 = 1;
    unsigned fi;

    if(t == 0)
        return 0;
    if(t == 1)
        return 1;

    for(unsigned i = 2 ; i <= t ; i++ )
    {
        fi = f1 + f2;
        f1 = f2;
        f2 = fi;
    }
    return fi;
}
