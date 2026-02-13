Extension { #name : 'GolapQueryPresenter' }

{ #category : '*Golap-Project' }
GolapQueryPresenter >> asJSON [
	^ Dictionary new
		at: 'transactionFilter' put: self transactionFilterSpec asJSON;
		at: 'itemFilter' put: self itemFilterSpec asJSON;
		at: 'granularity'
			put:
			(Dictionary new
				at: 'transaction' put: granularityTransaction selectedItem;
				at: 'node' put: granularityNode selectedItem;
				yourself);
		at: 'dimension'
			put:
			(Dictionary new
				at: 'field' put: dimensionsKey selectedItem;
				at: 'values' put: dimensionsValues text asString trim;
				yourself);
		at: 'minSupport' put: self minSupport;
		at: 'minConfidence' put: self minConfidence;
		at: 'minLift' put: self minLift;
		at: 'minJaccard' put: self minJaccard;
		at: 'minPMI' put: self minPMI;
		at: 'sortKey' put: sortKey text asString trim;
		at: 'sendMax' put: sendMax text asString trim;
		at: 'isolatedNodes' put: isolatedNodesCheckBox state;
		at: 'deadlineTimer' put: deadlineTimer text asString trim;
		yourself
]

{ #category : '*Golap-Project' }
GolapQueryPresenter >> fromJSON: aDicitonary [
	aDicitonary
		at: 'transactionFilter'
			ifPresent:
			[ :obj | self transactionFilterSpec: (GolapTransactionFilterSpec fromJSON: obj) ];
		at: 'itemFilter'
			ifPresent:
				[ :obj | self itemFilterSpec: (GolapTransactionFilterSpec fromJSON: obj) ];
		at: 'granularity'
			ifPresent: [ :dict | 
			dict
				at: 'transaction'
					ifPresent: [ :string | granularityTransaction selectItem: string ];
				at: 'node'
					ifPresent: [ :string | granularityNode selectItem: string ] ];
		at: 'dimension'
			ifPresent: [ :dict | 
			dict
				at: 'field'
					ifPresent: [ :string | dimensionsKey selectItem: string ];
				at: 'values'
					ifPresent: [ :string | dimensionsValues text: string ] ];
		at: 'minSupport' ifPresent: [ :string | self minSupport: string ];
		at: 'minConfidence'
			ifPresent: [ :string | self minConfidence: string ];
		at: 'minLift' ifPresent: [ :string | self minLift: string ];
		at: 'minJaccard' ifPresent: [ :string | self minJaccard: string ];
		at: 'minPMI' ifPresent: [ :string | self minPMI: string ];
		at: 'sortKey' ifPresent: [ :string | sortKey text: string ];
		at: 'isolatedNodes'
			ifPresent: [ :bool | isolatedNodesCheckBox state: bool ];
		at: 'deadlineTimer'
			ifPresent: [ :string | deadlineTimer text: string ]
]
