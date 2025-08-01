#!/usr/bin/env python3
"""
Translation Helper Script for Ubuzima App
Helps extract strings and prepare them for translation using free tools.
"""

import json
import re
import os
from typing import Dict, List, Set

class TranslationHelper:
    def __init__(self, project_root: str):
        self.project_root = project_root
        self.l10n_dir = os.path.join(project_root, 'lib', 'l10n')
        
    def extract_strings_from_dart(self, file_path: str) -> Set[str]:
        """Extract hardcoded strings from Dart files."""
        strings = set()
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Find Text widget strings
            text_pattern = r"Text\s*\(\s*['\"]([^'\"]+)['\"]"
            strings.update(re.findall(text_pattern, content))
            
            # Find string literals in common UI patterns
            patterns = [
                r"labelText:\s*['\"]([^'\"]+)['\"]",
                r"hintText:\s*['\"]([^'\"]+)['\"]", 
                r"title:\s*['\"]([^'\"]+)['\"]",
                r"subtitle:\s*['\"]([^'\"]+)['\"]",
                r"content:\s*['\"]([^'\"]+)['\"]",
            ]
            
            for pattern in patterns:
                strings.update(re.findall(pattern, content))
                
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            
        return strings
    
    def scan_project_for_strings(self) -> Dict[str, Set[str]]:
        """Scan entire project for translatable strings."""
        all_strings = {}
        
        # Scan lib directory
        lib_dir = os.path.join(self.project_root, 'lib')
        
        for root, dirs, files in os.walk(lib_dir):
            for file in files:
                if file.endswith('.dart'):
                    file_path = os.path.join(root, file)
                    relative_path = os.path.relpath(file_path, self.project_root)
                    strings = self.extract_strings_from_dart(file_path)
                    
                    if strings:
                        all_strings[relative_path] = strings
                        
        return all_strings
    
    def load_arb_file(self, language: str) -> Dict:
        """Load existing ARB file."""
        arb_path = os.path.join(self.l10n_dir, f'app_{language}.arb')
        
        try:
            with open(arb_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"@@locale": language}
        except Exception as e:
            print(f"Error loading {arb_path}: {e}")
            return {"@@locale": language}
    
    def generate_translation_template(self, strings: Set[str]) -> Dict:
        """Generate a template for translation."""
        template = {}
        
        for string in sorted(strings):
            # Create a key from the string
            key = self.string_to_key(string)
            template[key] = string
            template[f"@{key}"] = {
                "description": f"Translation for: {string}"
            }
            
        return template
    
    def string_to_key(self, string: str) -> str:
        """Convert a string to a valid ARB key."""
        # Remove special characters and convert to camelCase
        key = re.sub(r'[^a-zA-Z0-9\s]', '', string)
        words = key.split()
        
        if not words:
            return "unknownString"
            
        # First word lowercase, rest title case
        key = words[0].lower()
        for word in words[1:]:
            key += word.capitalize()
            
        return key or "unknownString"
    
    def find_missing_translations(self) -> Dict[str, List[str]]:
        """Find strings that need translation."""
        # Load existing ARB files
        en_arb = self.load_arb_file('en')
        fr_arb = self.load_arb_file('fr')
        rw_arb = self.load_arb_file('rw')
        
        # Get all keys from English (base language)
        en_keys = {k for k in en_arb.keys() if not k.startswith('@') and k != '@@locale'}
        fr_keys = {k for k in fr_arb.keys() if not k.startswith('@') and k != '@@locale'}
        rw_keys = {k for k in rw_arb.keys() if not k.startswith('@') and k != '@@locale'}
        
        missing = {
            'french': list(en_keys - fr_keys),
            'kinyarwanda': list(en_keys - rw_keys)
        }
        
        return missing
    
    def export_for_translation(self, language: str, output_file: str):
        """Export strings that need translation to a simple format."""
        en_arb = self.load_arb_file('en')
        target_arb = self.load_arb_file(language)
        
        # Find missing translations
        en_keys = {k for k in en_arb.keys() if not k.startswith('@') and k != '@@locale'}
        target_keys = {k for k in target_arb.keys() if not k.startswith('@') and k != '@@locale'}
        
        missing_keys = en_keys - target_keys
        
        # Create export data
        export_data = []
        for key in sorted(missing_keys):
            export_data.append({
                'key': key,
                'english': en_arb[key],
                'translation': '',
                'context': en_arb.get(f'@{key}', {}).get('description', '')
            })
        
        # Write to file
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(export_data, f, indent=2, ensure_ascii=False)
            
        print(f"Exported {len(export_data)} strings to {output_file}")
        print(f"Use free translation tools to translate and then import back.")
    
    def import_translations(self, language: str, import_file: str):
        """Import completed translations back to ARB file."""
        # Load import data
        with open(import_file, 'r', encoding='utf-8') as f:
            import_data = json.load(f)
        
        # Load existing ARB
        arb_data = self.load_arb_file(language)
        
        # Add new translations
        for item in import_data:
            if item['translation'].strip():
                key = item['key']
                arb_data[key] = item['translation']
                
                # Add description if not exists
                desc_key = f"@{key}"
                if desc_key not in arb_data:
                    arb_data[desc_key] = {
                        "description": item.get('context', f"Translation for: {item['english']}")
                    }
        
        # Save updated ARB file
        arb_path = os.path.join(self.l10n_dir, f'app_{language}.arb')
        with open(arb_path, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, indent=2, ensure_ascii=False)
            
        print(f"Imported translations to {arb_path}")

def main():
    """Main function for command line usage."""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python translation_helper.py scan                    # Scan for hardcoded strings")
        print("  python translation_helper.py missing                 # Find missing translations")
        print("  python translation_helper.py export <lang> <file>    # Export for translation")
        print("  python translation_helper.py import <lang> <file>    # Import translations")
        return
    
    # Assume script is in scripts/ directory
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    helper = TranslationHelper(project_root)
    
    command = sys.argv[1]
    
    if command == 'scan':
        strings = helper.scan_project_for_strings()
        print("Found translatable strings in:")
        for file_path, file_strings in strings.items():
            print(f"\n{file_path}:")
            for string in sorted(file_strings):
                print(f"  - {string}")
                
    elif command == 'missing':
        missing = helper.find_missing_translations()
        print("Missing translations:")
        for lang, keys in missing.items():
            print(f"\n{lang.title()}: {len(keys)} missing")
            for key in keys[:10]:  # Show first 10
                print(f"  - {key}")
            if len(keys) > 10:
                print(f"  ... and {len(keys) - 10} more")
                
    elif command == 'export' and len(sys.argv) >= 4:
        language = sys.argv[2]
        output_file = sys.argv[3]
        helper.export_for_translation(language, output_file)
        
    elif command == 'import' and len(sys.argv) >= 4:
        language = sys.argv[2]
        import_file = sys.argv[3]
        helper.import_translations(language, import_file)
        
    else:
        print("Invalid command or missing arguments")

if __name__ == '__main__':
    main()
