int y = 3;

typedef enum
{
    false = ( 1 == 0 ),
    true = ( ! false )
} bool;

int main(void) {
    bool x = false;
    if (y < 5) {
        x = true;
    }
    return x;
}
