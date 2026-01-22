Extension { #name : 'GolapOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapOverviewPresenter >> asJSON [

	^ {
		  ('scale' -> scale).
		  ('offset' -> {
			   offset x.
			   offset y }).
		  ('nodePositions'
		   -> (nodePositions associations collect: [ :assoc |
					    assoc key -> {
						    assoc value x.
						    assoc value y } ]) asDictionary) } asDictionary
]

{ #category : '*Golap-Project' }
GolapOverviewPresenter >> fromJSON: aDictionary [

	aDictionary
		at: 'scale' ifPresent: [ :num | scale := num ];
		at: 'offset'
		ifPresent: [ :array | offset := array first @ array second ];
		at: 'nodePositions' ifPresent: [ :dict |
				nodePositions := (dict associations collect: [ :assoc |
						                  assoc key
						                  -> (assoc value first @ assoc value second) ])
					                 asDictionary ]
]
