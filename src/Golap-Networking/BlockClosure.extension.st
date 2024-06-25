Extension { #name : 'BlockClosure' }

{ #category : '*Golap-Networking' }
BlockClosure >> forkAndWait [
	"Suspend current process and execute self in new process, when it completes resume current process"

	| semaphore |
	semaphore := Semaphore new.
	[ self
		ensure: [ semaphore signal ] ] fork.
	semaphore wait
]
