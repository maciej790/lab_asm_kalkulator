#include <iostream>
#include <string>

using namespace std;

string dzielenie(string liczba1, string liczba2) {
    string wynik = "";
    int dzielna = stoi(liczba1);
    int dzielnik = stoi(liczba2);

    while (dzielna >= dzielnik) {
        int reszta = 0;
        while (dzielna >= dzielnik) {
            dzielna -= dzielnik;
            reszta += 1;
        }
        wynik += to_string(reszta);
    }

    return wynik;
}

int main() {
    string liczba1, liczba2;
    cout << "Podaj pierwszą liczbę: ";
    cin >> liczba1;
    cout << "Podaj drugą liczbę: ";
    cin >> liczba2;

    string wynik = dzielenie(liczba1, liczba2);

    cout << "Wynik dzielenia: " << wynik << endl;

    return 0;
}