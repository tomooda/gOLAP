Extension { #name : 'GolapClusteredHeatmapPresenter' }

{ #category : '*Golap-Project' }
GolapClusteredHeatmapPresenter >> asJSON [

	| json |
	json := super asJSON.
	json
		at: 'rank' put: rankSlider value;
		at: 'showsClusterMeans' put: showsClusterMeansCheckBox state;
		at: 'showsSingletonClusters'
		put: showsSingletonClustersCheckBox state;
		at: 'showsClusterBoundaries'
		put: showsClusterBoundariesCheckBox state.
	evaluatorDropList selectedItem ifNotNil: [ :assoc |
		json at: 'evaluatorDropList' put: assoc key ].
	^ json
]

{ #category : '*Golap-Project' }
GolapClusteredHeatmapPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'rank' ifPresent: [ :number | rankSlider value: number ];
		at: 'showsClusterMeans'
		ifPresent: [ :bool | showsClusterMeansCheckBox state: bool ];
		at: 'showsSingletonClusters'
		ifPresent: [ :bool | showsSingletonClustersCheckBox state: bool ];
		at: 'showsClusterBoundaries'
		ifPresent: [ :bool | showsClusterBoundariesCheckBox state: bool ];
		at: 'evaluatorDropList' ifPresent: [ :string |
				self updateEvaluatorDropList.
				evaluatorDropList selectItem: (evaluatorDropList items
							 detect: [ :assoc | assoc key = string ]
							 ifNone: [ nil ]) ].
	self updateTree
]
