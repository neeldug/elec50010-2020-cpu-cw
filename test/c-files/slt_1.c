int y = 3, z = 5;

typedef enum
{
    false = ( 1 == 0 ),
    true = ( ! false )
} bool;

int main(void) {
    bool x = false;
    if (y < z) {
        x = true;
    }
    return x;
}
