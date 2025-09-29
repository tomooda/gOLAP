Class {
	#name : 'GolapFriendOverviewPresenter',
	#superclass : 'GolapOverviewPresenter',
	#category : 'Golap-UI-Overview',
	#package : 'Golap-UI',
	#tag : 'Overview'
}

{ #category : 'accessing' }
GolapFriendOverviewPresenter >> availableEdges [

	^ (self golapModelDo: [ :golapModel | golapModel friendsEdges ])
		  ifNil: [ Array new ]
]
