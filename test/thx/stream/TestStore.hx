package thx.stream;

import utest.Assert;
import thx.stream.Store;
using thx.stream.TestStream;
using thx.promise.Promise;

class TestStore {
  public function new() {}

  public function testStore() {
    var store = new Store(reducer, 1);
    Assert.equals(1, store.get());
    store.apply(Increment);
    Assert.equals(2, store.get());
    store.apply(Decrement);
    Assert.equals(1, store.get());
    store.apply(SetTo(0));
    Assert.equals(0, store.get());
  }

  public function testStreamInitialValue() {
    var store = new Store(reducer, 0);
    store
      .stream()
      .assertFirstValues([0]);
  }

  public function testStream() {
    var store = new Store(reducer, 0);
    store
      .stream()
      .assertFirstValues([0,1,3]);
    store
      .apply(Increment)
      .apply(SetTo(3));
  }

  public function testMiddleware() {
    var store = new Store(reducer, middleware, 0);
    store
      .stream()
      .assertFirstValues([0,1,10]);
    store
      .apply(Increment);
  }

  public function reducer(state: Int, message: TestStoreMessage) {
    return switch message {
      case Increment: state + 1;
      case Decrement: state - 1;
      case SetTo(value): value;
    };
  }

  public function middleware(message: TestStoreMessage): Promise<Array<TestStoreMessage>> {
    return Promise.value(switch message {
      case Increment: [SetTo(10)];
      case _: [];
    });
  }
}

enum TestStoreMessage {
  Increment;
  Decrement;
  SetTo(value: Int);
}
