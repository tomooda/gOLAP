Extension { #name : 'GolapColorsAppearance' }

{ #category : '*Golap-Project' }
GolapColorsAppearance >> asJSON [

	^ (self colorSelectors collect: [ :selector |
			   selector
			   -> ((self perform: selector asSymbol) ifNotNil: #asHexString) ])
		  asOrderedDictionary
		  at: 'name-selection' put: nameList selectedItem;
		  at: 'color-selection'
		  put: (colorList selectedItem ifNotNil: #asHexString);
		  yourself
]

{ #category : '*Golap-Project' }
GolapColorsAppearance >> fromJSON: aDictionary [

	self colorSelectors do: [ :selector |
			aDictionary at: selector ifPresent: [ :hexString |
					self
						perform: (selector , ':') asSymbol
						with: (Color fromHexString: hexString) ] ].
	aDictionary
		at: 'name-selection'
		ifPresent: [ :string | nameList selectItem: string ];
		at: 'color-selection' ifPresent: [ :hexString |
				colorList selectItem:
						(hexString ifNotNil: [ Color fromHexString: hexString ]) ]
]
