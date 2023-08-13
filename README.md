fork of ultimate-geography (see original readme in
README-ultimate_geography.md) that adds population from wikipedia

methodology:

1. use [https://wikitable2csv.ggor.de/] to download
[https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population]
as a csv
1. name it `wikipedia-list_of_countries_and_dependencies_by_population.csv`
`. maybe adjust `manual.csv` entries idk
1. `pipenv install`
1. `pipenv run ./wiki-to-anki.bash > src/data/main.csv`
1. edit `recipies/source_to_anki.yaml` and add `population: Population` to `&default_columns_and_fields` (L57 when I did it)
1. `pipenv run brainbrew run recipies/source_to_anki.yaml`
1. import your new deck with crowdanki!
