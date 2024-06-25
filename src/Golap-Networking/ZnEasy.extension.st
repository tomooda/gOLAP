Extension { #name : 'ZnEasy' }

{ #category : '*Golap-Networking' }
ZnEasy class >> post: urlObject data: entity timeout: seconds [
	^ self client
		url: urlObject;
		entity: entity;
		timeout: seconds;
		post;
		response
]
