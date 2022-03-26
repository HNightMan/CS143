class Node inherits IO
{
	value:String;
	next:Node;

	init(a1:String,a2:Node):Node
	{
		{
			value<-a1;
			next<-a2;
			self;
		}
	};

	retallvalue():String
	{
		if isvoid next then
			value.concat("\n")
		else
			value.concat(" -> ").concat(next.retallvalue())
		fi
	};

	retvalue():String
	{
		value
	};

	retnext():Node
	{
		next
	};
};

class Stack inherits A2I
{
	top:Node;

	retallvalue():String
	{
		top.retallvalue()
	};

	push(a:String):Object
	{
		top<-(new Node).init(a,top)
	};

	rettop():Node
	{
		top
	};

	pop():String
	{
		let tmpstr:String in
		{
			tmpstr<-top.retvalue();
			top<-top.retnext();
			tmpstr;
		}
	};

	add():Object
	{
		{
			pop();
			push(i2a(a2i(pop())+a2i(pop())));
		}
	};

	sweap():Object
	{
		let tmp1:String,
			tmp2:String in
		{
			pop();
			tmp1<-pop();
			tmp2<-pop();
			push(tmp1);
			push(tmp2);
		}
	};
};

class Main inherits IO
{
	stack:Stack<-new Stack;

	main():Object
	{
		let instr:String in
		while true loop
		{
			out_string(">");
			instr<-in_string();
			if instr="x" then
			{
				out_string("Exit!\n");
				abort();
			}
			else if instr="d" then
				out_string(stack.retallvalue())
			else if instr="e" then
				excute()
			else
				stack.push(instr)
			fi fi fi;
		}pool
	};

	excute():Object
	{
		if isvoid stack.rettop() then
			out_string("Do nothing\n")
		else if stack.rettop().retvalue()="+" then
			stack.add()
		else if stack.rettop().retvalue()="s" then
			stack.sweap()
		else
			out_string("Do nothing\n")
		fi fi fi
	};
};
