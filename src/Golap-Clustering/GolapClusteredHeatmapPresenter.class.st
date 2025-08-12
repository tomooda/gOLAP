Class {
	#name : 'GolapClusteredHeatmapPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#category : 'Golap-Clustering-Heatmap',
	#package : 'Golap-Clustering',
	#tag : 'Heatmap'
}

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> grid [

	^ 10
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> updateCanvas [
	| builder |
	builder := RSHeatmap new.
	builder container: self canvas.
	
	tree graphNodesDo: [ :columnNode |
		tree graphNodesDo: [ :rowNode |
			 ]]
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> windowTitle [

	^ 'Heatmap'
]
