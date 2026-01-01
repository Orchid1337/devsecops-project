#!/bin/bash

echo "🧹 CZYSZCZENIE RAPORTÓW"
echo "========================"

cd ~/devsecops-project/reports 2>/dev/null || { 
    echo "❌ Brak katalogu reports"
    exit 1 
}

# Policz przed
COUNT_BEFORE=$(ls -1 *.txt 2>/dev/null | wc -l)
echo "Przed: $COUNT_BEFORE plików"
echo ""

# Pokaż opcje
echo "Wybierz opcję czyszczenia:"
echo "1) Usuń WSZYSTKO (cały folder reports)"
echo "2) Zachowaj 2 najnowsze z każdego typu"
echo "3) Zachowaj tylko dzisiejsze"
echo "4) ANULUJ"
echo ""
read -p "Twój wybór (1-4): " choice
echo ""

case $choice in
    1)
        # OPCJA 1: USUŃ WSZYSTKO
        echo "⚠️  USUWANIE WSZYSTKICH RAPORTÓW!"
        echo "To usunie $(ls -1 *.txt 2>/dev/null | wc -l) plików."
        read -p "Na pewno? (tak/NIE): " confirm
        
        if [[ "$confirm" == "tak" ]]; then
            rm -f *.txt
            echo "✅ Usunięto WSZYSTKIE pliki z reports/"
        else
            echo "❌ Anulowano"
        fi
        ;;
    
    2)
        # OPCJA 2: ZACHOWAJ 2 NAJNOWSZE Z KAŻDEGO TYPU
        echo "🧹 Zachowuję 2 najnowsze pliki każdego typu..."
        
        TOTAL_REMOVED=0
        
        # Znajdź unikalne typy analizując nazwy plików
        # Najpierw wyodrębnij prefixy (część przed datą)
        TYPES=$(ls *.txt 2>/dev/null | while read file; do
            # Usuń datę i rozszerzenie, zostaw tylko typ
            echo "$file" | sed 's/-20[0-9][0-9][0-9][0-9][0-9][0-9]_.*\.txt//' | sed 's/\.txt//'
        done | sort | uniq)
        
        echo "Znalezione typy:"
        echo "$TYPES"
        echo ""
        
        for TYPE in $TYPES; do
            # Znajdź wszystkie pliki tego typu, posortuj od najnowszych
            FILES=$(ls -t ${TYPE}*.txt 2>/dev/null | head -20)
            COUNT=$(echo "$FILES" | wc -l)
            
            if [ "$COUNT" -gt 2 ]; then
                # Zachowaj 2 najnowsze
                TO_KEEP=$(echo "$FILES" | head -2)
                # Usuń resztę
                TO_REMOVE=$(echo "$FILES" | tail -n +3)
                
                REMOVE_COUNT=$(echo "$TO_REMOVE" | wc -l)
                TOTAL_REMOVED=$((TOTAL_REMOVED + REMOVE_COUNT))
                
                echo "  $TYPE: zachowuję 2, usuwam $REMOVE_COUNT"
                rm -f $TO_REMOVE 2>/dev/null
            fi
        done
        
        COUNT_AFTER=$(ls -1 *.txt 2>/dev/null | wc -l)
        echo "✅ Usunięto: $TOTAL_REMOVED plików"
        echo "✅ Pozostało: $COUNT_AFTER plików"
        ;;
    
    3)
        # OPCJA 3: ZACHOWAJ TYLKO DZISIEJSZE
        TODAY=$(date +%Y%m%d)
        echo "🧹 Zachowuję tylko dzisiejsze raporty ($TODAY)..."
        
        # Znajdź pliki które NIE są z dzisiaj
        FILES_TO_REMOVE=$(ls *.txt 2>/dev/null | grep -v "$TODAY" || true)
        REMOVE_COUNT=$(echo "$FILES_TO_REMOVE" | wc -l)
        
        if [ "$REMOVE_COUNT" -gt 0 ]; then
            echo "Usuwanie $REMOVE_COUNT starych plików:"
            echo "$FILES_TO_REMOVE" | head -10
            if [ "$REMOVE_COUNT" -gt 10 ]; then
                echo "... i $((REMOVE_COUNT - 10)) więcej"
            fi
            
            rm -f $FILES_TO_REMOVE
            COUNT_AFTER=$(ls -1 *.txt 2>/dev/null | wc -l)
            echo "✅ Usunięto: $REMOVE_COUNT plików"
            echo "✅ Pozostało: $COUNT_AFTER plików"
        else
            echo "ℹ️  Wszystkie pliki są dzisiejsze"
        fi
        ;;
    
    4)
        echo "❌ Anulowano"
        ;;
    
    *)
        echo "❌ Nieprawidłowy wybór"
        ;;
esac

# Pokaż podsumowanie
echo ""
echo "📊 PODSUMOWANIE:"
ls -la *.txt 2>/dev/null | wc -l | xargs echo "Plików w reports/:"
du -sh . 2>/dev/null | awk '{print "Rozmiar folderu:", $1}'
