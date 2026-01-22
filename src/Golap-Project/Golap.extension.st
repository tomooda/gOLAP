Extension { #name : 'Golap' }

{ #category : '*Golap-Project' }
Golap >> asJSON [

	^ self basicAsJSON
		  at: 'url' put: url asString;
		  at: 'query' put: query;
		  at: 'dimensions'
		  put: (dimensions associations collect: [ :assoc |
						   {
							   assoc key.
							   assoc value asJSON } ]);
		  at: 'merges' put: (merges collect: [ :assoc |
						   {
							   assoc key.
							   assoc value } ]);
		  at: 'pins' put: pins asArray;
		  at: 'selections' put: selections asArray;
		  at: 'baseList' put: baseList selectedItem;
		  at: 'frontList' put: frontList selectedItem;
		  at: 'edgesAppearance' put: edgesAppearancePresenter asJSON;
		  at: 'colorsAppearance' put: colorsAppearancePresenter asJSON;
		  at: 'itemInfoRetriever' put: itemInfoRetriever asJSON;
		  at: 'itemList' put: itemList asJSON;
		  at: 'edgeList' put: edgeList asJSON;
		  at: 'comment' put: commentText text;
		  at: 'polishOverview' put: polishOverviewPresenter asJSON;
		  at: 'friendOverview' put: friendOverviewPresenter asJSON;
		  at: 'articulationPointOverview'
		  put: articulationPointOverviewPresenter asJSON;
		  at: 'elaboration' put: elaborationPresenter asJSON;
		  at: 'dandelion' put: dandelionPresenter asJSON;
		  at: 'hedge' put: hedgePresenter asJSON;
		  at: 'heatmap' put: heatmapPresenter asJSON;
		  at: 'visualizationNotebook-selectedPageIndex'
		  put: visualizationNotebook selectedPageIndex;
		  yourself
]

{ #category : '*Golap-Project' }
Golap >> fromJSON: aDictionary [

	self blockUpdateModelWhile: [
			aDictionary
				at: 'url' ifPresent: [ :string | url := string asZnUrl ];
				at: 'query' ifPresent: [ :dict | query := dict ];
				at: 'dimensions' ifPresent: [ :array |
						array do: [ :pair |
									self
										addDimension: (GolapModel new
												 fromJSON: pair second;
												 yourself)
										named: pair first ] ];
				at: 'baseList'
				ifPresent: [ :string |
				string ifNotNil: [ baseList selectItem: string ] ];
				at: 'frontList'
				ifPresent: [ :string |
				string ifNotNil: [ frontList selectItem: string ] ];
				at: 'merges' ifPresent: [ :array |
					merges := (array collect: [ :pair | pair first -> pair second ])
						          asOrderedCollection ];
				at: 'pins'
				ifPresent: [ :array | pins := array asOrderedCollection ];
				at: 'selections'
				ifPresent: [ :array | selections := array asSet ];
				at: 'edgesAppearance'
				ifPresent: [ :json | edgesAppearancePresenter fromJSON: json ];
				at: 'colorsAppearance'
				ifPresent: [ :json | colorsAppearancePresenter fromJSON: json ];
				at: 'itemInfoRetriever'
				ifPresent: [ :json |
				itemInfoRetriever := GolapItemInfoRetriever fromJSON: json ];
				at: 'itemList' ifPresent: [ :json | itemList fromJSON: json ];
				at: 'edgeList' ifPresent: [ :json | edgeList fromJSON: json ];
				at: 'comment' ifPresent: [ :text | commentText text: text ];
				at: 'polishOverview'
				ifPresent: [ :json | polishOverviewPresenter fromJSON: json ];
				at: 'friendOverview'
				ifPresent: [ :json | friendOverviewPresenter fromJSON: json ];
				at: 'articulationPointOverview'
				ifPresent: [ :json |
				articulationPointOverviewPresenter fromJSON: json ];
				at: 'elaboration'
				ifPresent: [ :json | elaborationPresenter fromJSON: json ];
				at: 'dandelion'
				ifPresent: [ :json | dandelionPresenter fromJSON: json ];
				at: 'hedge' ifPresent: [ :json | hedgePresenter fromJSON: json ];
				at: 'heatmap'
				ifPresent: [ :json | heatmapPresenter fromJSON: json ];
				at: 'visualizationNotebook-selectedPageIndex'
				ifPresent: [ :integer |
				visualizationNotebook selectPageIndex: integer ].
			self basicFromJSON: aDictionary.
			self selectedPageChanged ]
]
