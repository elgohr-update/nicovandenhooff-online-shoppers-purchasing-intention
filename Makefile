all : docs/

# download data
data/raw/online_shoppers_intention.csv : src/download_data.py
	python src/download_data.py --url=https://archive.ics.uci.edu/ml/machine-learning-databases/00468/online_shoppers_intention.csv --out_path=data/raw/online_shoppers_intention.csv

# preprocess data
data/processed/train-eda.csv data/processed/test-eda.csv data/processed/train.csv data/processed/test.csv : src/data_preprocess.py data/raw/online_shoppers_intention.csv
	python src/data_preprocess.py --input_path=data/raw/online_shoppers_intention.csv --output_path=data/processed/ --test_size=0.2

# create eda charts and save to file
reports/images/chart_target_distribution.png reports/images/chart_numeric_var_distribution.png reports/images/chart_correlation.png reports/images/chart_density.png : src/eda_charts.py data/processed/train-eda.csv data/processed/test-eda.csv
	python src/eda_charts.py --input_path=data/processed/train-eda.csv --output_path=reports/images/

# model selection
results/model_selection_results.csv reports/images/model_cm.png.png reports/images/model_pr_curves.png : src/model_selection.py data/processed/train.csv data/processed/test.csv
	python src/model_selection.py --train=data/processed/train.csv --test=data/processed/test.csv --output_path_images=reports/images/ --output_path_csv=results/model_selection_results.csv

# tune model
results/classification_report.csv reports/images/Final_RandomForest_cm.png : src/tune_model.py data/processed/train.csv data/processed/test.csv
	python src/tune_model.py --train=data/processed/train.csv --test=data/processed/test.csv --output_path_images=reports/images/ --output_path_csv=results/classification_report.csv

# generate jupyter book
reports/_build/ : results/model_selection_results.csv reports/images/model_cm.png.png reports/images/model_pr_curves.png results/classification_report.csv reports/images/Final_RandomForest_cm.png reports/images/chart_target_distribution.png reports/images/chart_numeric_var_distribution.png reports/images/chart_correlation.png reports/images/chart_density.png
	jupyter-book build --all reports/

# automate copying files to docs/ for rendering the report on github.io
docs/ : reports/_build/
	cp -a reports/_build/html/. docs/

# clean up intermediate and results files
clean:
	rm -f data/raw/*.csv
	rm -f data/processed/*.csv
	rm -f reports/images/*.png
	rm -f results/*.csv
	rm -rf reports/_build/*
	rm -rf docs/*