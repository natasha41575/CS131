/* Implement a new class GetNSet, which is halfway between 
 * unsynchronized and synchronized, in that it does not use 
 * synchronized code, but instead uses volatile accesses to 
 * array elements. Implement it with the get and set methods. 
 */

import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State {
	private byte maxval;
	private AtomicIntegerArray value;

	/* constructors */

	GetNSet(byte[] v) {
		this.maxval = 127;

		int[] arr = new int[v.length];
		for (int i = 0; i < arr.length; i++) {
			arr[i] = v[i];
		}
		this.value = new AtomicIntegerArray(arr);
	}

	GetNSet(byte[] v, byte m) {
		this.maxval = m;

		int[] arr = new int[v.length];
		for (int i = 0; i < arr.length; i++) {
			arr[i] = v[i];
		}
		this.value = new AtomicIntegerArray(arr);
	}

	/* methods */

	@Override
	public int size() {
		return value.length();
	}

	@Override
	public byte[] current() {
		byte[] arr = new byte[this.size()];
		for (int i = 0; i < arr.length; i++) {
			arr[i] = (byte) this.value.get(i);
		}
		return arr;
	}

	@Override
	public boolean swap(int i, int j) {
		int val_i = this.value.get(i);
		int val_j = this.value.get(j);
		if (val_i <= 0 || val_j >= this.maxval) {
			return false;
		} else {
			this.value.set(i, val_i-1);
			this.value.set(j, val_j+1);
			return true;
		}
	}
}