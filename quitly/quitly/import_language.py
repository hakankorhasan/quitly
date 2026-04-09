import sys
import json
import os

def main():
    if len(sys.argv) != 3:
        print("Kullanım: python3 import_language.py <dil_kodu> <dosya_adi.txt>")
        print("Örnek: python3 import_language.py de almanca_metinler.txt")
        sys.exit(1)

    lang_code = sys.argv[1]
    input_file = sys.argv[2]

    if not os.path.exists(input_file):
        print(f"Hata: {input_file} dosyası bulunamadı.")
        sys.exit(1)

    quotes = []
    with open(input_file, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            # Boş satırları ve başlıkları (### ile başlayan) geç
            if not line or line.startswith('###'):
                continue
            
            # Eğer satır '* ' veya '- ' ile başlıyorsa temizle
            if line.startswith('* '):
                line = line[2:]
            elif line.startswith('- '):
                line = line[2:]
                
            quotes.append(line.strip())

    expected_count = 200
    if len(quotes) != expected_count:
        print(f"Uyarı: {expected_count} adet söz bekleniyordu ama {len(quotes)} adet bulundu!")
        print("Lütfen txt dosyasındaki çeviri sayısını kontrol et.")
        sys.exit(1)

    # Localizable.xcstrings dosyasını güncelle
    xcstrings_path = "Localizable.xcstrings"
    with open(xcstrings_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    for i in range(expected_count):
        key = f"mq_quote_{i}"
        
        # Eğer string hiç yoksa (olmamalı ama önlem)
        if key not in data["strings"]:
            data["strings"][key] = { "localizations": {} }
            
        # İlgili dile çeviriyi ekle/güncelle
        data["strings"][key]["localizations"][lang_code] = {
            "stringUnit": {
                "state": "translated",
                "value": quotes[i]
            }
        }

    with open(xcstrings_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Başarılı! {lang_code.upper()} dili için {len(quotes)} motivasyon sözü projeye entegre edildi.")

if __name__ == "__main__":
    main()
