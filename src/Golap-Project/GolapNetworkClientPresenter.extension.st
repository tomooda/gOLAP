Extension { #name : 'GolapNetworkClientPresenter' }

{ #category : '*Golap-Project' }
GolapNetworkClientPresenter >> asJSON [

	^ urlInput text asString trim
		  ifNotEmpty: [ :urlString |
			  | dict |
			  dict := Dictionary new
				          at: 'url' put: urlInput text asString trim;
				          yourself.
			  usesRawQuery = true
				  ifTrue: [ dict at: 'rawQuery' put: queryPalettePresenter query ]
				  ifFalse: [
					  queryPresenter asJSON keysAndValuesDo: [ :key :value |
						  dict at: key put: value ] ].
			  dict ]
		  ifEmpty: [ nil ]
]
