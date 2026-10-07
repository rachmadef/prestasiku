<?php

$a = 10;
$b = 20;

function swap(&$x, &$y)
{
    $temp = $x;
    $x = $y;
    $y = $temp;
}

swap($a, $b);

echo "Nilai a adalah " . $a . "<br>";
echo "Nilai b adalah " . $b . "<br>";

function tukar(&$x1, &$y2)
{
    [$x1, $y2] = [$y2, $x1];
}

tukar($a, $b);

echo "Nilai a adalah " . $a . "<br>";
echo "Nilai b adalah " . $b . "<br>";

function bandingkan($a1, $b1)
{
    if ($a1 > $b1) {
        echo "a lebih besar dari b<br>";
    } elseif ($a1 < $b1) {
        echo "b lebih besar dari a<br>";
    } else {
        echo "a sama dengan b<br>";
    }
}

bandingkan($a, $b);
