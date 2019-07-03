/* Design and implement a new class BetterSafe of your choice, 
 * which achieves better performance than Synchronized while 
 * retaining 100% reliability.
 */

import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Lock;

class BetterSafe implements State {
	private byte[] value;
	private byte maxval;
	private Lock rlock;

	/* constructors */

	BetterSafe(byte[] v) {
		this.value = v;
		this.maxval = 127;
		this.rlock = new ReentrantLock();
	}

	BetterSafe(byte[] v, byte m) {
		this.value = v;
		this.maxval = m;
		this.rlock = new ReentrantLock();
	}

	/* methods */

	@Override
	public int size() {
		return this.value.length;
	}

	@Override
	public byte[] current() {
		return this.value;
	}

	@Override
	public boolean swap(int i, int j) {
		rlock.lock();
		if (this.value[i] <= 0 || this.value[j] >= this.maxval) {
			this.rlock.unlock();
			return false;
		} else {
			this.value[i]--;
			this.value[j]++;
			this.rlock.unlock();
			return true;
		}
	}
}
