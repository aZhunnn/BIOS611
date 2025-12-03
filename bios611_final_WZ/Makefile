.PHONY: clean 

clean:
	rm -r ./figures/*
	rm -f *.md 
	rm -rf *_files
	rm -f report.html

clustering_prep.RData: coffee_health.csv data_preparation.R
	Rscript data_preparation.R

pca_cluster_visualization.png: clustering_prep.RData clustering_analysis.R
	Rscript clustering_analysis.R
	
elbow_method_plot.png: coffee_health.csv clustering_analysis.R 
	Rscript clustering_analysis.R
	
silhouette_plot.png: coffee_health.csv clustering_analysis.R 
	Rscript clustering_analysis.R
	
cluster_profile_heatmap.png: coffee_health.csv clustering_analysis.R 
	Rscript clustering_analysis.R
	
coffee_bmi_scatter.png: coffee_health.csv clustering_analysis.R 
	Rscript clustering_analysis.R
	
correlation_heatmap_R.png: coffee_health.csv correlation_heatmap.R
	Rscript correlation_heatmap.R
	
caffeine_vs_sleep.png: coffee_health.csv eda.R
	Rscript eda.R
		
report.html: coffee_health.csv pca_cluster_visualization.png elbow_method_plot.png silhouette_plot.png cluster_profile_heatmap.png coffee_bmi_scatter.png correlation_heatmap_R.png caffeine_vs_sleep.png report.Rmd
	Rscript -e "rmarkdown::render(\"report.Rmd\", output_format=\"html_document\")"
	