Extension { #name : 'GolapCSVLauncher' }

{ #category : '*Golap-Project' }
GolapCSVLauncher >> asJSON [

	^ self basicAsJSON
		  at: 'pairPresenter' put: pairPresenter asJSON;
		  at: 'pairsTable' put: pairsTable selectedIndex;
		  at: 'nodeImporterPresenter' put: nodeImporterPresenter asJSON;
		  at: 'edgeImporterPresenter' put: edgeImporterPresenter asJSON;
		  yourself
]

{ #category : '*Golap-Project' }
GolapCSVLauncher >> fromJSON: aDictionary [

	aDictionary
		at: 'pairPresenter'
		ifPresent: [ :json | pairPresenter fromJSON: json ];
		at: 'pairsTable'
		ifPresent: [ :integer | pairsTable selectIndex: integer ];
		at: 'nodeImporterPresenter'
		ifPresent: [ :json | nodeImporterPresenter fromJSON: json ];
		at: 'edgeImporterPresenter'
		ifPresent: [ :json | edgeImporterPresenter fromJSON: json ].
	self basicFromJSON: aDictionary
]
