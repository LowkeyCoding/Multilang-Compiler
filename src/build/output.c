#include <stdio.h>
char tape[2147483647/2];
char *ptr;
int main() {
  ptr=tape;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  while (*ptr){
    ptr++;
    (*ptr)++;
    (*ptr)++;
    (*ptr)++;
    (*ptr)++;
    while (*ptr){
      ptr++;
      (*ptr)++;
      (*ptr)++;
      ptr++;
      (*ptr)++;
      (*ptr)++;
      (*ptr)++;
      ptr++;
      (*ptr)++;
      (*ptr)++;
      (*ptr)++;
      ptr++;
      (*ptr)++;
      ptr--;
      ptr--;
      ptr--;
      ptr--;
      (*ptr)--;
      }
    ptr++;
    (*ptr)++;
    ptr++;
    (*ptr)++;
    ptr++;
    (*ptr)--;
    ptr++;
    ptr++;
    (*ptr)++;
    while (*ptr){
      ptr--;
      }
    ptr--;
    (*ptr)--;
    }
  ptr++;
  ptr++;
  putchar(*ptr);
  ptr++;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  putchar(*ptr);
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  putchar(*ptr);
  putchar(*ptr);
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  putchar(*ptr);
  ptr++;
  ptr++;
  putchar(*ptr);
  ptr--;
  (*ptr)--;
  putchar(*ptr);
  ptr--;
  putchar(*ptr);
  (*ptr)++;
  (*ptr)++;
  (*ptr)++;
  putchar(*ptr);
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  putchar(*ptr);
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  (*ptr)--;
  putchar(*ptr);
  ptr++;
  ptr++;
  (*ptr)++;
  putchar(*ptr);
  ptr++;
  (*ptr)++;
  (*ptr)++;
  putchar(*ptr);
return 1;
}