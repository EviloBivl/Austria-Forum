 
//   Created by Paul Neuhold on 22.01.16.
//

import Foundation
struct CategoriesListed {
    
    
    static func GetBeautyCategoryFromUrlString (_ url: String?) -> String {
        
        if let url = url {
        for str in categoriesRaw {
                if url.contains(str) {
                    let beautyIndex = categoriesRaw.firstIndex(of: str)
                    return categoriesBeautiful[beautyIndex!]
                }
            }
        }
        
        return ""

    }
    
    static let categoriesRaw = [
        
        "AEIOU",
        "Wissenssammlungen/Biographien",
        "AustriaWiki",
        "Wissenssammlungen/Essays",
        "web-books",
        "Natur",
        "Wissenssammlungen/Fauna",
        "Wissenssammlungen/Flora",
        "Wissenssammlungen/Fossilien",
        "Wissenssammlungen/Haus-_und_Gartenpflanzen",
        "Wissenssammlungen/Mineralien",
        "Alltagskultur",
        "Wissenssammlungen/ABC_zur_Volkskunde_Österreichs",
        "Wissenssammlungen/Symbole",
        "Heimatlexikon",
        "Wissenssammlungen/Blogmobil",
        "Wissenssammlungen/Briefmarken",
        "Wissenssammlungen/Münzen",
        "Wissenssammlungen/Sprichwörter",
        "Wissenssammlungen/Österreichisches Deutsch",
        "Zum_Tag/Kalenderblatt",
        "Kunst_und_Kultur",
        "Community/Zeitgenössische_Bildende_Kunst",
        "Wissenssammlungen/Alsergrund",
        "Wissenssammlungen/Bibliothek/Peter Stöger Biographie",
        "Wissenssammlungen/Bilddatenbank Kurt Regschek",
        "Wissenssammlungen/Burgen_und_Schlösser",
        "Wissenssammlungen/Essays/Architektur-ISG",
        "Wissenssammlungen/Klimt Gedenkstätte",
        "Wissenssammlungen/Museen",
        "Wissenssammlungen/Musik-Lexikon",
        "Wissenssammlungen/Musik_Kolleg",
        "Wissenssammlungen/Sakralbauten",
        "Bilder_und_Videos",
        "Wissenssammlungen/Bildlexikon_Österreich",
        "Wissenssammlungen/Bibliothek",
        "Wissenssammlungen/Bücher_über_Österreich",
        "Wissenssammlungen/Historische_Bilder",
        "Wissenssammlungen/Panoramalexikon",
        "Wissenssammlungen/Weitere_Bildsammlungen",
        "Wissenssammlungen/Bauernhausbilder",
        "Videos",
        "Politik_und_Geschichte",
        "Wissenssammlungen/Chronik_Österreichs",
        "Wissenssammlungen/Damals_in_der_Steiermark",
        "Wissenssammlungen/Denkmale",
        "Wissenssammlungen/Denkmale_Bundesländer",
        "Wissenssammlungen/Europawissen",
        "Wissenssammlungen/Geschichtsatlas",
        "Wissenssammlungen/Politisches_Wissen",
        "Wissenssammlungen/Schicksalsorte",
        "Wissenssammlungen/iuvavum",
        "Wissenssammlungen/Limes",
        "Wissenschaft_und_Wirtschaft",
        "AEIOU/Fachhochschulen-Übersicht",
        "Sparkling_Science",
        "Wissenssammlungen/Erfinder",
        "Wissenssammlungen/Industriebilder",
        "Wissenssammlungen/Institutionen_und_Unternehmen",
        "Wissenssammlungen/Neues_aus_der_Wissenschaft",
        "Wissenssammlungen/Studiengänge_und_Ausbildung",
        "Wissenssammlungen/Universitäten_und_Fachhochschulen",
        "Wissenssammlungen/Wissenschaftler",
        "Geography",
        "Community",
        "Web_Books",
        "Web-Books",
        "web_books",
        "Unternehmen"]
    
    static let categoriesBeautiful = [
        
        "AEIOU",
        "Wissenssammlungen - Biographien",
        "AustriaWiki",
        "Wissenssammlungen - Essays",
        "Web Books",
        "Natur",
        "Wissenssammlungen - Fauna",
        "Wissenssammlungen - Flora",
        "Wissenssammlungen - Fossilien",
        "Wissenssammlungen - Haus- und Gartenpflanzen",
        "Wissenssammlungen - Mineralien",
        "Alltagskultur",
        "Wissenssammlungen - ABC zur Volkskunde Österreichs",
        "Wissenssammlungen - Symbole",
        "Heimatlexikon",
        "Wissenssammlungen - Blogmobil",
        "Wissenssammlungen - Briefmarken",
        "Wissenssammlungen - Münzen",
        "Wissenssammlungen - Sprichwörter",
        "Wissenssammlungen - Österreichisches Deutsch",
        "Zum Tag - Kalenderblatt",
        "Kunst und Kultur",
        "Community - Zeitgenössische Bildende Kunst",
        "Wissenssammlungen - Alsergrund",
        "Wissenssammlungen - Bibliothek - Peter Stöger Biographie",
        "Wissenssammlungen - Bilddatenbank Kurt Regschek",
        "Wissenssammlungen - Burgen und Schlösser",
        "Wissenssammlungen - Essays - Architektur-ISG",
        "Wissenssammlungen - Klimt Gedenkstätte",
        "Wissenssammlungen - Museen",
        "Wissenssammlungen - Musik-Lexikon",
        "Wissenssammlungen - Musik Kolleg",
        "Wissenssammlungen - Sakralbauten",
        "Bilder und Videos",
        "Wissenssammlungen - Bildlexikon Österreich",
        "Wissenssammlungen - Bibliothek",
        "Wissenssammlungen - Bücher über Österreich",
        "Wissenssammlungen - Historische Bilder",
        "Wissenssammlungen - Panoramalexikon",
        "Wissenssammlungen - Weitere Bildsammlungen",
        "Wissenssammlungen - Bauernhausbilder",
        "Videos",
        "Politik und Geschichte",
        "Wissenssammlungen - Chronik Österreichs",
        "Wissenssammlungen - Damals in der Steiermark",
        "Wissenssammlungen - Denkmale",
        "Wissenssammlungen - Denkmale Bundesländer",
        "Wissenssammlungen - Europawissen",
        "Wissenssammlungen - Geschichtsatlas",
        "Wissenssammlungen - Politisches Wissen",
        "Wissenssammlungen - Schicksalsorte",
        "Wissenssammlungen - iuvavum",
        "Wissenssammlungen - Limes",
        "Wissenschaft und Wirtschaft",
        "AEIOU - Fachhochschulen-Übersicht",
        "Sparkling Science",
        "Wissenssammlungen - Erfinder",
        "Wissenssammlungen - Industriebilder",
        "Wissenssammlungen - Institutionen und Unternehmen",
        "Wissenssammlungen - Neues aus der Wissenschaft",
        "Wissenssammlungen - Studiengänge und Ausbildung",
        "Wissenssammlungen - Universitäten und Fachhochschulen",
        "Wissenssammlungen - Wissenschaftler",
        "Geography",
        "Community",
        "Web Book",
        "Web Book",
        "Web book",
        "Unternehmen in Österreich"]
    

}
