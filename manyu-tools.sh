#!/bin/bash

# ASCII ART
show_banner() {
    clear
    echo -e "\e[1;33m"
    cat << "EOF"
███╗░░░███╗░█████╗░███╗░░██╗██╗░░░██╗██╗░░░██╗
████╗░████║██╔══██╗████╗░██║╚██╗░██╔╝██║░░░██║
██╔████╔██║███████║██╔██╗██║░╚████╔╝░██║░░░██║
██║╚██╔╝██║██╔══██║██║╚████║░░╚██╔╝░░██║░░░██║
██║░╚═╝░██║██║░░██║██║░╚███║░░░██║░░░╚██████╔╝
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝░░░╚═╝░░░░╚═════╝░

TOOLS BY MANYU
EOF
    echo -e "\e[0m"
}

# WHOIS Domain Function
whois_domain() {
    # Function to check if whois is installed
    check_dependencies() {
        if ! command -v whois &> /dev/null; then
            echo "❌ Error: whois is not installed."
            echo "Install it with:"
            echo "  Ubuntu/Debian: sudo apt-get install whois"
            echo "  CentOS/RHEL: sudo yum install whois"
            echo "  Arch: sudo pacman -S whois"
            exit 1
        fi
    }

    # Function to extract and display whois info with more aggressive parsing
    display_whois_info() {
        domain=$1
        echo -e "\n\e[1;36m🔍 WHOIS INFORMATION FOR: $domain\e[0m"
        
        # Get raw whois data
        raw_data=$(whois "$domain" 2>&1)
        
        # Check domain availability
        if [[ "$raw_data" == *"No match"* ]] || [[ "$raw_data" == *"NOT FOUND"* ]] || [[ "$raw_data" == *"Available"* ]]; then
            echo -e "\n\e[1;31m❌ DOMAIN IS AVAILABLE FOR REGISTRATION\e[0m\n"
            return
        fi
        
        echo -e "\n\e[1;32m✅ DOMAIN IS REGISTERED\e[0m"
        
        # 1. Domain Status
        echo -e "\n\e[1;33m=== DOMAIN STATUS ===\e[0m"
        echo "$raw_data" | grep -i "domain status:" | sort -u | sed 's/^[ \t]*//;s/[ \t]*$//'
        
        # 2. Registrar Information (more comprehensive)
        echo -e "\n\e[1;33m=== REGISTRAR INFORMATION ===\e[0m"
        echo "$raw_data" | grep -iE "registrar:|registrar name:|registrar organization:|registrar iana id:|registrar url:|registrar abuse contact:" | \
        sort -u | sed 's/^[ \t]*//;s/[ \t]*$//'
        
        # 3. Important Dates (more variations)
        echo -e "\n\e[1;33m=== IMPORTANT DATES ===\e[0m"
        echo "$raw_data" | grep -iE "creation date:|created on:|created date:|expiration date:|expiry date:|updated date:|last updated:|registered on:" | \
        sort -u | sed 's/^[ \t]*//;s/[ \t]*$//'
        
        # 4. Name Servers (all variations)
        echo -e "\n\e[1;33m=== NAME SERVERS ===\e[0m"
        echo "$raw_data" | grep -iE "name server:|nserver:|dns:" | sort -u | sed 's/^[ \t]*//;s/[ \t]*$//'
        
        # 5. Contact Information (more aggressive search)
        echo -e "\n\e[1;33m=== CONTACT INFORMATION ===\e[0m"
        
        # Registrant
        echo -e "\n\e[1;34mRegistrant:\e[0m"
        echo "$raw_data" | grep -iEA1 "registrant (name|organization):" | sed 's/^[ \t]*//;s/[ \t]*$//'
        echo "$raw_data" | grep -iE "registrant (email|phone|street|city|state|postal code|country):" | sed 's/^[ \t]*//;s/[ \t]*$//'
        
        # Admin
        echo -e "\n\e[1;34mAdmin:\e[0m"
        echo "$raw_data" | grep -iEA1 "admin (name|organization):" | sed 's/^[ \t]*//;s/[ \t]*$//'
        echo "$raw_data" | grep -iE "admin (email|phone|street|city|state|postal code|country):" | sed 's/^[ \t]*//;s/[ \t]*$//'
        
        # Tech
        echo -e "\n\e[1;34mTechnical:\e[0m"
        echo "$raw_data" | grep -iEA1 "tech (name|organization):" | sed 's/^[ \t]*//;s/[ \t]*$//'
        echo "$raw_data" | grep -iE "tech (email|phone|street|city|state|postal code|country):" | sed 's/^[ \t]*//;s/[ \t]*$//'
        
        # 6. Additional Technical Information
        echo -e "\n\e[1;33m=== TECHNICAL INFORMATION ===\e[0m"
        echo "$raw_data" | grep -iE "dnssec:|whois server:|referral url:|registry domain id:|domain record last updated:" | \
        sort -u | sed 's/^[ \t]*//;s/[ \t]*$//'
        
        # 7. Raw Data Preview (last 10 lines)
        echo -e "\n\e[1;33m=== RAW DATA PREVIEW ===\e[0m"
        echo "$raw_data" | tail -n 10 | sed 's/^/    /'
    }

    # Main function
    main() {
        read -p "MASUKKAN DOMAIN WEBSITE TARGET: " domain
        
        # Validate domain input
        if [[ -z "$domain" ]]; then
            echo "❌ Error: Domain cannot be empty!"
            exit 1
        fi
        
        # Remove http:// or https:// if present
        domain=$(echo "$domain" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
        
        display_whois_info "$domain"
    }

    # Check dependencies and run main function
    check_dependencies
    main
}

# Subdomain Finder Function
subdomain_finder() {
    # Check dependencies
    if ! command -v curl &> /dev/null; then
        echo "❌ Error: curl is required but not installed!"
        exit 1
    fi

    read -p "MASUKKAN DOMAIN WEBSITE TARGET: " domain

    # Validate input
    if [[ -z "$domain" ]]; then
        echo "❌ Error: Domain cannot be empty!"
        exit 1
    fi

    # Clean domain input
    domain=$(echo "$domain" | sed -e 's|^[^/]*//||' -e 's|/.*$||' -e 's|^www\.||')

    echo -e "\n\e[1;36m🔍 Scanning subdomains for: $domain\e[0m"
    echo -e "\e[1;33m⏳ Querying HackerTarget API...\e[0m\n"

    # API endpoint
    api_url="https://api.hackertarget.com/hostsearch/?q=$domain"

    # Make the API request
    response=$(curl -s "$api_url")

    # Check if we got a valid response
    if [[ "$response" == *"API count exceeded"* ]]; then
        echo "❌ Error: HackerTarget API limit reached (free tier)"
        echo "Try again later or use a different tool"
        exit 1
    elif [[ "$response" == *"error"* ]] || [[ "$response" == *"no records"* ]]; then
        echo "❌ No subdomains found or invalid response"
        exit 1
    fi

    # Process and display results with IPs
    echo -e "\e[1;32m✅ Found subdomains:\e[0m\n"
    echo "$response" | awk -F',' '{printf "• %-30s %s\n", $1, $2}' | sort -u
}

# Main Menu
while true; do
    show_banner
    echo -e "\e[1;36m[1] Whois Domain"
    echo -e "[2] Subdomain Finder"
    echo -e "[3] Exit\e[0m"
    
    read -p "MASUKAN NOMOR: " choice
    
    case $choice in
        1)
            whois_domain
            ;;
        2)
            subdomain_finder
            ;;
        3)
            echo -e "\n\e[1;32mTerima kasih telah menggunakan tools ini!\e[0m"
            exit 0
            ;;
        *)
            echo -e "\n\e[1;31mPilihan tidak valid! Silakan pilih 1, 2, atau 3.\e[0m"
            ;;
    esac
    
    read -p $'\n\e[1;33mTekan Enter untuk kembali ke menu utama...\e[0m'
done
