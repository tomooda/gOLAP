Extension { #name : 'GolapArticulationPointOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapArticulationPointOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'friendsRank' put: friendsRankField number;
		  at: 'minimumIslandSize' put: minimumIslandSizeField number;
		  at: 'articulationPoint'
		  put: (articulationPointList selectedItem ifNotNil: #id);
		  yourself
]

{ #category : '*Golap-Project' }
GolapArticulationPointOverviewPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'friendsRank'
		ifPresent: [ :integer | friendsRankField number: integer ];
		at: 'minimumIslandSize'
		ifPresent: [ :integer | minimumIslandSizeField number: integer ].
	self updateGraph.
	aDictionary at: 'articulationPoint' ifPresent: [ :string |
			string ifNotNil: [
					articulationPointList selectItem: (articulationPointList items
							 detect: [ :node | node id = string ]
							 ifNone: [ nil ]) ] ]
]
