x = [-5:0.1:5];
range = 101;
y = zeros(range, 1);
z = zeros(range, 1);
for i = 1:range
	y(i) = exp(-(x(i)^2)/2);
	z(i) = sin(x(i)*6.5)*y(i);
end
plot(x,z,"linewidth",20);