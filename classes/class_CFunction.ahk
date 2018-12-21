; Base class for custom "Function" objects
class CFunction
{
	__Call(method, args*)
	{
		if IsObject(method) || (method == "")
			return method ? this.Call(method, args*) : this.Call(args*)
	}
}
