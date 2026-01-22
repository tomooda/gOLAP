Extension { #name : 'GolapItemList' }

{ #category : '*Golap-Project' }
GolapItemList >> asJSON [

	^ {
		  ('markers' -> (markerDropList items collect: #asJSON)).
		  ('markers-selectedIndex' -> markerDropList selectedIndex) }
		  asDictionary
]

{ #category : '*Golap-Project' }
GolapItemList >> fromJSON: aDictionary [

	aDictionary
		at: 'markers' ifPresent: [ :array |
				markerDropList items: (array collect: [ :dict |
									 (GolapAbstractMarker fromJSON: dict)
										 updateIn: self;
										 yourself ]).
				self updateItemsList ];
		at: 'markers-selectedIndex'
		ifPresent: [ :integer | markerDropList selectIndex: integer ]
]
