; ahk: console
#NoEnv
#Warn All, StdOut
SetBatchLines -1

#Include <testcase-libs>

#Include %A_ScriptDir%\..\queue.ahk

class QueueTest extends TestCase {

	@Test_class() {
		this.assertEquals(new Queue().__Class, "Queue")
		this.assertTrue(new Queue().hasKey("queueSize"))
		this.assertTrue(new Queue().hasKey("content"))
		this.assertEquals(new Queue().queueSize, 0)
		this.assertTrue(IsObject(new Queue().content))
		this.assertTrue(IsFunc(new Queue().__new))
		this.assertTrue(IsFunc(new Queue().push))
		this.assertTrue(IsFunc(new Queue().pop))
		this.assertTrue(IsFunc(new Queue().length))
		this.assertTrue(IsFunc(new Queue().clear))
	}

	@Test__new() {
		this.assertEquals(new Queue(3).queueSize, 3)
		this.assertException(Queue, "__new", "", "", -3)
		this.assertException(Queue, "__new", "", "", "test")
	}

	@Test_pushUnlimited() {
		wday := new Queue()
		this.assertEmpty(wday.push("Monday"))
		this.assertEmpty(wday.push("Tuesday"))
		this.assertEmpty(wday.push("Wednesday"))
		this.assertEmpty(wday.push("Thursday"))
		this.assertEmpty(wday.push("Friday"))
		this.assertEmpty(wday.push("Saturday"))
		this.assertEmpty(wday.push("Sunday"))
		this.assertEquals(wday.content.minIndex(), 1)
		this.assertEquals(wday.content.maxIndex(), 7)
		this.assertEquals(wday.content[1], "Monday")
		this.assertEquals(wday.content[2], "Tuesday")
		this.assertEquals(wday.content[3], "Wednesday")
		this.assertEquals(wday.content[4], "Thursday")
		this.assertEquals(wday.content[5], "Friday")
		this.assertEquals(wday.content[6], "Saturday")
		this.assertEquals(wday.content[7], "Sunday")
	}

	@Test_pushLimited() {
		wday := new Queue(3)
		this.assertEmpty(wday.push("Monday"))
		this.assertEmpty(wday.push("Tuesday"))
		this.assertEmpty(wday.push("Wednesday"))
		this.assertEquals(wday.push("Thursday"), "Monday")
		this.assertEquals(wday.push("Friday"), "Tuesday")
		this.assertEquals(wday.push("Saturday"), "Wednesday")
		this.assertEquals(wday.push("Sunday"), "Thursday")
		this.assertEquals(wday.content.minIndex(), 1)
		this.assertEquals(wday.content.maxIndex(), 3)
		this.assertEquals(wday.content[1], "Friday")
		this.assertEquals(wday.content[2], "Saturday")
		this.assertEquals(wday.content[3], "Sunday")
		this.assertEquals(wday.content[4], "")
	}

	@Test_pop() {
		workday := new Queue()
		workday.push("Monday")
		workday.push("Tuesday")
		workday.push("Wednesday")
		workday.push("Thursday")
		workday.push("Friday")
		this.assertEquals(workday.pop(), "Monday")
		this.assertEquals(workday.pop(), "Tuesday")
		this.assertEquals(workday.pop(), "Wednesday")
		this.assertEquals(workday.pop(), "Thursday")
		this.assertEquals(workday.content.maxIndex(), 1)
		this.assertEquals(workday.pop(), "Friday")
		this.assertEquals(workday.pop(), "")
	}

	@Test_Pop_Keep() {
		workday := new Queue()
		workday.push("Monday")
		workday.push("Tuesday")
		workday.push("Wednesday")
		workday.push("Thursday")
		workday.push("Friday")
		this.assertEquals(workday.pop(), "Monday")
		this.assertEquals(workday.pop(true), "Tuesday")
		this.assertEquals(workday.pop(true), "Tuesday")
		this.assertEquals(workday.pop(true), "Tuesday")
		this.assertEquals(workday.content.maxIndex(), 4)
		this.assertEquals(workday.pop(), "Tuesday")
		this.assertEquals(workday.pop(), "Wednesday")
		this.assertEquals(workday.pop(), "Thursday")
		this.assertEquals(workday.content.maxIndex(), 1)
		this.assertEquals(workday.pop(), "Friday")
		this.assertEquals(workday.pop(), "")
	}

	@Test_length() {
		weekend := new Queue()
		this.assertEquals(weekend.length(), 0)
		weekend.push("Saturday")
		weekend.push("Sunday")
		this.assertEquals(weekend.length(), 2)
		weekend.pop()
		this.assertEquals(weekend.length(), 1)
	}

	@Test_clear() {
		weekend := new Queue()
		this.assertEquals(weekend.clear(), 0)
		weekend.push("Saturday")
		weekend.push("Sunday")
		this.assertEquals(weekend.clear(), 2)
	}
}

exitapp QueueTest.runTests()
