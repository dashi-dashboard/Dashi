package eventbus

import (
	"sync"
)

// EventBus provides a common method to allow parts of the server to listen
// for events from other parts.
type EventBus struct {
	subscribers      map[string][]chan interface{}
	subscribersMutex sync.RWMutex
}

// New creates a new instance of EventBus ready to use.
func New() *EventBus {
	return &EventBus{
		subscribers:      make(map[string][]chan interface{}),
		subscribersMutex: sync.RWMutex{},
	}
}

// Subscribe creates and returns a new channel which will listen on the provided topic.
func (eb *EventBus) Subscribe(topic string) chan interface{} {
	channel := make(chan interface{})

	eb.subscribersMutex.Lock()
	defer eb.subscribersMutex.Unlock()

	eb.subscribers[topic] = append(eb.subscribers[topic], channel)

	return channel
}

// UnSubscribe stops a channel listening on the particular topic and cleans up.
func (eb *EventBus) UnSubscribe(topic string, channel chan interface{}) {
	eb.subscribersMutex.Lock()
	defer eb.subscribersMutex.Unlock()

	var subscribers []chan interface{}

	for _, subscriber := range eb.subscribers[topic] {
		if subscriber != channel {
			subscribers = append(subscribers, subscriber)
		}
	}

	eb.subscribers[topic] = subscribers
	close(channel)
}

// Publish broadcasts a the provided event to all subscribers of topic.
func (eb *EventBus) Publish(topic string, event interface{}) {
	eb.subscribersMutex.RLock()
	defer eb.subscribersMutex.RUnlock()

	if subscribers, ok := eb.subscribers[topic]; ok {
		for _, subscriber := range subscribers {
			select {
			case subscriber <- event:
				break
			default:
				break
			}
		}
	}
}
