#!/usr/bin/env bash

run_create_movie() {

    # Handle parameters
    local name="$1"
    local deposit="${2:-Movies}"

    # Create movie folder
    local name=$(echo "$name" | sed 's/[\/:*?"<>|]//g')
    mkdir -p "$deposit/$name"

    # Create movie file
    touch "$deposit/$name/$name.mkv"

}

run_create_serie() {

    # Handle parameters
    local name="$1"
    local deposit="${2:-Series}"

    # Create serie folder
    local encoded=$(echo "$name" | jq -sRr @uri)
    local res=$(curl -s "https://api.tvmaze.com/search/shows?q=$encoded")
    local id=$(echo "$res" | jq '.[0].show.id')
    local name=$(echo "$res" | jq -r '.[0].show.name')
    local premier=$(echo "$res" | jq -r '.[0].show.premiered')
    [[ -z "$id" || -z "$name" ]] && return 1 || :
    local name=$(echo "$name" | sed 's/[\/:*?"<>|]//g')
    local yr=$(echo "$premier" | cut -d '-' -f 1)
    local series_dir="$deposit/$name ($yr)"
    mkdir -p "$series_dir"

    # Create series episodes
    local eps=$(curl -s "https://api.tvmaze.com/shows/$id/episodes")
    echo "$eps" | jq -c '.[]' | while read -r ep; do
        local s_id=$(echo "$ep" | jq -r '.season')
        local ep_num=$(echo "$ep" | jq -r '.number')
        local season_dir="$series_dir/S$(printf "%02d" $s_id)"
        mkdir -p "$season_dir"
        local ep_file="S$(printf "%02d" $s_id)E$(printf "%02d" $ep_num).mkv"
        touch "$season_dir/$ep_file"
    done

}

main() {

    # Create popular movies
    local popular_movies=(
        "Oppenheimer (2023)"
        "Barbie (2023)"
        "Guardians of the Galaxy Vol. 3 (2023)"
        "The Flash (2023)"
        "Spider-Man: Across the Spider-Verse (2023)"
        "Avatar: The Way of Water (2022)"
        "Black Panther: Wakanda Forever (2022)"
        "Doctor Strange in the Multiverse of Madness (2022)"
        "Top Gun: Maverick (2022)"
        "Dune (2021)"
        "The Suicide Squad (2021)"
        "No Time to Die (2021)"
    )
    for movie in "${popular_movies[@]}"; do
        echo "Creating movie: $movie"
        run_create_movie "$movie"
    done

    # Create popular series
    local popular_series=(
        "Attack on Titan"
        "Blue Lock"
        "Demon Slayer"
        "Foundation"
        "Jujutsu Kaisen"
        "Loki"
        "The Expanse"
        "The Peripheral"
        "The Three-Body Problem"
        "The Witcher"
        "Tokyo Revengers"
    )
    for serie in "${popular_series[@]}"; do
        echo "Creating serie: $serie"
        run_create_serie "$serie"
    done

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
