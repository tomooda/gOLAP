Extension { #name : 'GolapFriendOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapFriendOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'friendsRank' put: friendsRankField number;
		  yourself
]

{ #category : '*Golap-Project' }
GolapFriendOverviewPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'friendsRank'
		ifPresent: [ :integer | friendsRankField number: integer ].
	self updateGraph
]
