Extension { #name : 'GolapCSVPairPresenter' }

{ #category : '*Golap-Project' }
GolapCSVPairPresenter >> asJSON [

	^ {
		  ('basepathField' -> basepathField text).
		  ('nodeCSVList-selection' -> nodeCSVList selectedItem).
		  ('edgeCSVList-selection' -> edgeCSVList selectedItem).
		  ('lastBasepath'
		   -> (self class basicLastBasepath ifNotNil: #fullName)) }
		  asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapCSVPairPresenter >> fromJSON: aDictionary [

	aDictionary
		at: 'basepathField'
		ifPresent: [ :string | basepathField text: string ];
		at: 'nodeCSVList-selection'
		ifPresent: [ :string | nodeCSVList selectItem: string ];
		at: 'edgeCSVList-selection'
		ifPresent: [ :string | edgeCSVList selectItem: string ];
		at: 'lastBasepath' ifPresent: [ :string |
				self class lastBasepath:
						(string ifNotNil: [ string asFileReference ifAbsent: [ nil ] ]) ]
]
